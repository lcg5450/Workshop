//
//  ContentView.swift
//  Purpleworks-Workshop
//
//  Created by gomgom on 9/10/25.
//

import SwiftUI

enum SidebarItem: Hashable {
    case createTeam
    case scoreboard
    case scoreboardWeb
    case etc
}

struct ContentView: View {
    @State private var selection: SidebarItem? = .createTeam

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: SidebarItem.createTeam) {
                    Label("랜덤 팀 생성", systemImage: "person.3")
                }
                NavigationLink(value: SidebarItem.scoreboardWeb) {
                    Label("점수 보드", systemImage: "globe")
                }
                NavigationLink(value: SidebarItem.scoreboard) {
                    Label("점수 보드", systemImage: "list.number")
                }
                NavigationLink(value: SidebarItem.etc) {
                    Label("기타", systemImage: "ellipsis.circle")
                }
            }
            .navigationTitle("메뉴")
        } detail: {
            switch selection {
            case .createTeam:
                WebTeamDividerView()
            case .scoreboardWeb:
                WebScoreboardView()
            case .scoreboard:
                ScoreboardView()
            case .etc:
                EtcView()
            case .none:
                EtcView()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct EtcView: View {
    var body: some View {
        ContentUnavailableView("기타", systemImage: "ellipsis", description: Text("추후 확장 영역입니다."))
            .navigationTitle("기타")
    }
}
