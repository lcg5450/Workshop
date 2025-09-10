//
//  WebTeamDividerView.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI
import SwiftData

struct WebTeamDividerView: View {
    var body: some View {
        LocalHTMLView(resource: "randomTeam", ext: "html")
            .navigationTitle("랜덤 팀 생성")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebTeamDividerImportView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Team.createdAt, order: .forward) private var teams: [Team]

    var body: some View {
        LocalHTMLBridgeView(resource: "randomTeam", ext: "html", messageName: "teamSync") { payload in
            // JS에서 { teams: [["이름1","이름2"], ["이름3",...]] } 형태로 받는다고 가정
            guard
                let dict = payload as? [String: Any],
                let arrays = dict["teams"] as? [[String]]
            else { return }

            // 예시: 기존 팀 모두 삭제 후 새로 생성
            for t in teams { context.delete(t) }

            for (idx, group) in arrays.enumerated() {
                // 그룹 이름이 아니라 "팀원"이라서, 팀은 그룹 개수만큼 생성 (팀 이름: 팀 1,2,..)
                let color = Color.teamPalette[idx % Color.teamPalette.count]
                let hex = color.toHex() ?? "#007AFF"
                let name = "팀 \(idx + 1)"
                context.insert(Team(name: name, colorHex: hex, score: 0))
                // ※ 팀원 → 개별 플레이어 모델이 있다면 여기에 함께 저장하면 됩니다.
            }
        }
        .navigationTitle("팀나누기(웹) • 임포트")
        .navigationBarTitleDisplayMode(.inline)
    }
}
