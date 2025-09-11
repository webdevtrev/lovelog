//
//  IdeasView.swift
//  Lovelog
//
//  Created by Trevor Cash on 9/4/25.
//

import SwiftUI

// MARK: - View

struct IdeasView: View {
    @State private var model = IdeasViewModel()
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !model.upcomingIdeas.isEmpty {
                    Section("Upcoming Dates") {
                        ForEach(model.upcomingIdeas) { idea in
                            UpcomingIdeaRow(idea: idea, user: model.userByID[idea.createdByUserID])
                        }
                    }
                }
                
                Section("Current Ideas") {
                    ForEach(model.currentIdeas) { idea in
                        IdeaRow(idea: idea, user: model.userByID[idea.createdByUserID])
                            .contentShape(Rectangle())
                            .onTapGesture {
                                path.append(idea)
                            }.swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    model.delete(idea)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Ideas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(CreateIdeaRoute())
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Create new idea")
                }
            }
            .navigationDestination(for: DateIdea.self) { idea in
                IdeaDetailView(idea: idea, user: model.userByID[idea.createdByUserID])
            }
            .navigationDestination(for: CreateIdeaRoute.self) { _ in
                CreateIdeaView()
            }
        }
    }
}


// MARK: - Destinations

struct CreateIdeaRoute: Hashable {}



// MARK: - Preview

#Preview {
    IdeasView()
}
