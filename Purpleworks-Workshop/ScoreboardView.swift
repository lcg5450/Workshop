//
//  ScoreboardView.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI
import SwiftData

struct ScoreboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Team.createdAt, order: .forward) private var teams: [Team]

    @State private var showAddTeam = false
    @State private var editTarget: Team? = nil

    var body: some View {
        VStack(spacing: 0) {
            if teams.isEmpty {
                ContentUnavailableView("팀이 없습니다",
                                       systemImage: "person.3",
                                       description: Text("‘팀 추가’ 버튼으로 팀을 만들어보세요."))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(teams) { team in
                        TeamRow(team: team) {
                            increment(team: team)
                        } onDecrement: {
                            decrement(team: team)
                        }
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button("점수 초기화") { team.score = 0 }
                            Button("팀 수정…") { editTarget = team }
                            Divider()
                            Button(role: .destructive) {
                                context.delete(team)
                            } label: {
                                Label("팀 삭제", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                increment(team: team)
                            } label: { Label("＋1", systemImage: "plus") }
                            .tint(.green)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                decrement(team: team)
                            } label: { Label("−1", systemImage: "minus") }
                            .tint(.orange)
                        }
                        .onTapGesture(count: 2) { editTarget = team } // 더블탭으로 수정
                    }
                    .onDelete { indexSet in
                        for i in indexSet { context.delete(teams[i]) }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("점수 보드")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    resetAllScores()
                } label: {
                    Label("모두 0점", systemImage: "arrow.counterclockwise")
                }
                Button {
                    showAddTeam = true
                } label: {
                    Label("팀 추가", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showAddTeam) {
            AddOrEditTeamView(mode: .add) { name, color in
                let hex = color.toHex() ?? "#007AFF"
                let newTeam = Team(name: name.isEmpty ? "팀 \(teams.count + 1)" : name,
                                   colorHex: hex,
                                   score: 0)
                context.insert(newTeam)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $editTarget) { team in
            AddOrEditTeamView(mode: .edit(existing: team)) { name, color in
                if !name.isEmpty { team.name = name }
                team.colorHex = color.toHex() ?? team.colorHex
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func increment(team: Team) {
        team.score += 1
    }

    private func decrement(team: Team) {
        team.score = max(0, team.score - 1) // 음수 방지
    }

    private func resetAllScores() {
        for t in teams { t.score = 0 }
    }
}

// MARK: - Row
struct TeamRow: View {
    @Bindable var team: Team
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    init(team: Team, onIncrement: @escaping () -> Void, onDecrement: @escaping () -> Void) {
        self._team = Bindable(wrappedValue: team)
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(team.color)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading) {
                Text(team.name)
                    .font(.headline)
                Text("점수: \(team.score)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 0) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.title3.weight(.semibold))
                        .frame(width: 44, height: 34)
                }
                .buttonStyle(.bordered)

                Text("\(team.score)")
                    .font(.title3.monospacedDigit())
                    .frame(minWidth: 56)
                    .padding(.horizontal, 8)

                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .frame(width: 44, height: 34)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.vertical, 6)
    }
}
