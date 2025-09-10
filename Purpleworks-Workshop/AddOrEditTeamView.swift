//
//  AddOrEditTeamView.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI

struct AddOrEditTeamView: View {
    enum Mode: Equatable {
        case add
        case edit(existing: Team)
    }

    let mode: Mode
    var onSubmit: (_ name: String, _ color: Color) -> Void

    @State private var name: String = ""
    @State private var selectedColor: Color = .randomTeam
    @Environment(\.dismiss) private var dismiss

    init(mode: Mode, onSubmit: @escaping (_ name: String, _ color: Color) -> Void) {
        self.mode = mode
        self.onSubmit = onSubmit
        switch mode {
        case .add:
            break
        case .edit(let existing):
            _name = State(initialValue: existing.name)
            _selectedColor = State(initialValue: existing.color)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("팀 정보") {
                    TextField("팀 이름", text: $name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("팀 색상")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Color.teamPalette.indices, id: \.self) { idx in
                                    let c = Color.teamPalette[idx]
                                    Circle()
                                        .fill(c)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle()
                                                .stroke(lineWidth: selectedColor.toHex() == c.toHex() ? 3 : 0)
                                                .foregroundStyle(.primary.opacity(0.7))
                                        )
                                        .onTapGesture { selectedColor = c }
                                        .accessibilityLabel(Text("색상 \(idx + 1)"))
                                }
                                Divider().frame(height: 32)
                                ColorPicker("직접 선택", selection: $selectedColor, supportsOpacity: false)
                                    .labelsHidden()
                                    .frame(width: 48, height: 32, alignment: .leading)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(mode == .add ? "팀 추가" : "팀 수정")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(mode == .add ? "추가" : "저장") {
                        onSubmit(name, selectedColor)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && mode == .add)
                }
            }
        }
    }
}
