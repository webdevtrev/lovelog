//
//  PartnerAdd.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/19/25.
//
import SwiftUI
import Foundation

let allUsers: [UserRow] = [
    UserRow(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        handle: "trevdev",
        name: "Trevor Cash",
        created_at: Date(),
        color: "#FF6B6B",
        couple_id: nil,
        onboarded: true,
        archived: false
    ),
    UserRow(
        id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
        handle: "sarahs",
        name: "Sarah Stone",
        created_at: Date(),
        color: "#6BCB77",
        couple_id: nil,
        onboarded: true,
        archived: false
    ),
    UserRow(
        id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
        handle: "markyb",
        name: "Mark Brown",
        created_at: Date(),
        color: "#4D96FF",
        couple_id: UUID(uuidString: "88888888-8888-8888-8888-888888888888"),
        onboarded: true,
        archived: false
    ),
    UserRow(
        id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
        handle: "jennyj",
        name: "Jenny Johnson",
        created_at: Date(),
        color: "#FFD93D",
        couple_id: nil,
        onboarded: false,
        archived: false
    )
]
// MARK: - Mock Users
let mockUser1 = UserRow(
    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
    handle: "trevor-c",
    name: "Trevor",
    created_at: Date(),
    color: "blue",
    couple_id: nil,
    onboarded: true,
    archived: false
)

let mockUser2 = UserRow(
    id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
    handle: "rashmi-c",
    name: "Rashmi",
    created_at: Date(),
    color: "pink",
    couple_id: nil,
    onboarded: true,
    archived: false
)

// MARK: - Mock Couple
let mockCouple = CoupleWithUsers(
    id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
    inviter_id: mockUser1.id,
    invited_id: mockUser2.id,
    accepted: true,
    created_at: Date(),
    inviter: mockUser1,
    invited: mockUser2
)

let mockCouples: [CoupleWithUsers] = [mockCouple]
let mockUsers: [UserRow] = [mockUser1, mockUser2]



struct PartnerAdd: View {
    var mocking: Bool = false
    @State var username = ""
    @State private var showingSheet = false
    @State private var selectedDetent: PresentationDetent = .large
    @State private var results : [UserRow] = []
    @EnvironmentObject private var authStore: SupabaseAuthStore

    var couplesRepo = CouplesRepository(supabase: supabase)
    
    @State private var incomingRequests: [CoupleWithUsers] = []
    @State private var outgoingRequests: [CoupleWithUsers] = []
    func getData(){
        if !mocking {
            Task{
                do {
                    incomingRequests = try await couplesRepo.fetchIncomingRequests(for: authStore.user!.id)
                    outgoingRequests = try await couplesRepo.fetchOutgoingRequests(for: authStore.user!.id)
                }
                catch{
                    print("error:", error.localizedDescription)
                }
            }

        } else{
            incomingRequests = mockCouples
            outgoingRequests = []
            results = allUsers
        }
            }
    func onAcceptTapped(coupleID: UUID) async {
      do {
          let updatedCouple = try await couplesRepo.acceptInvite(coupleID: coupleID)
          // Update local state/UI from updatedCouple
      } catch {
        // Present a user-friendly error
        print("Accept invite failed: \(error)")
      }
    }
    func onRejectTapped(coupleID: UUID) async {
        do{
            try await couplesRepo.rejectInvite(coupleID: coupleID)
            incomingRequests.removeAll { $0.id == coupleID }
        } catch{
            print("Reject invite failed: \(error)")
        }
    }
    func onCancelInvite(coupleID: UUID) async {
        do{
            try await couplesRepo.rejectInvite(coupleID: coupleID)
            outgoingRequests = []
        } catch{
            print("Reject invite failed: \(error)")
        }
    }
    func onInviteUserTapped(userID: UUID) async{
        do{
            let couple = try await couplesRepo.inviteUser(inviter: authStore.user!.id, invited: userID)
            showingSheet = false
            outgoingRequests = [couple]
        }
        catch{
            print("Invite failed: \(error)")
        }
        
    }
    var body: some View {
        VStack(spacing: 16) {
            if outgoingRequests.isEmpty{
                Button("Search for your partner"){
                    selectedDetent = .large
                    showingSheet = true
                }.buttonStyle(.glassProminent)
            }
            else{
                VStack(spacing: 16){
                    let name = outgoingRequests.first?.invited.name ?? "your partner"

                    Text("Invite pending with \(name). Ask them to open Love Log to accept.")
                        .foregroundStyle(.primary).font(.title2).multilineTextAlignment(.center)
                    Text("or")
                    Button("Cancel Invite"){
                        Task{
                            await onCancelInvite(coupleID: outgoingRequests.first!.id)
                        }
                    }
                }
                
            }
            if !incomingRequests.isEmpty{
            VStack{
                Text("Incoming Pending Requests")
                    .foregroundStyle(.primary).font(.title2)
                List {
                    ForEach(incomingRequests) { request in
                        HStack(spacing: 8){
                            VStack(alignment: .leading){
                                Text(request.inviter.name ?? "").font(.headline)
                                Text(request.inviter.handle ?? "").font(.subheadline).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button{
                                Task{
                                    await onAcceptTapped(coupleID: request.id)
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .imageScale(.large)
                            }
                            .tint(.green)
                            .buttonStyle(.bordered)
                            Button{
                                Task{
                                    await onRejectTapped(coupleID: request.id)
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .imageScale(.large)
                            }
                            .tint(.red)
                            .buttonStyle(.bordered)
                        }
                        
                    }
                }
            }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.background)
        .navigationTitle("Find your partner")
        .sheet(isPresented: $showingSheet) {
            VStack {
                TextField("Partner's Name or Username", text: $username)
                    .appTextFieldStyle()
                    .onSubmit {
                        Task{
                            do {
                                results =  try await searchUsers(by: username)
                                print(results)

                            } catch{
                                
                            }
                        }
                    }
                List{
                    ForEach(results) { user in
                        HStack{
                            VStack(alignment: .leading){
                                Text(user.name!)
                                    .font(.headline)
                                Text(user.handle!)
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                            Spacer()
                            Button("Invite"){
                                Task{
                                    await onInviteUserTapped(userID: user.id)
                                }

                            }
                        }
                    }
                }
                Spacer()
            }.padding(32)
            .presentationDetents([.large], selection: $selectedDetent)
            .presentationDragIndicator(.visible)
        }
        .onAppear(){
            getData()
        }
    }
}

#Preview{
    PartnerAdd(mocking: true)
}
