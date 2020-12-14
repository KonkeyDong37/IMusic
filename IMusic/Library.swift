//
//  Library.swift
//  IMusic
//
//  Created by Андрей on 07.12.2020.
//

import SwiftUI
import URLImage

struct Library: View {
    
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showAlert = false
    @State private var track: SearchViewModel.Cell!
    
    var tabBarDelegate: MainTabBarControllerDelegate?
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button(action: {
                            self.settrackDetailViewDelegate()
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximizeTrackDetailController(viewModel: self.track)
                        }, label: {
                            Image(systemName: "play.fill")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9889323115, green: 0.1831878126, blue: 0.3349292278, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9594140649, green: 0.9537104964, blue: 0.9637982249, alpha: 1)))
                                .cornerRadius(10)
                        })
                        Button(action: {
                            self.tracks = UserDefaults.standard.savedTracks()
                        }, label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .accentColor(Color.init(#colorLiteral(red: 0.9889323115, green: 0.1831878126, blue: 0.3349292278, alpha: 1)))
                                .background(Color.init(#colorLiteral(red: 0.9594140649, green: 0.9537104964, blue: 0.9637982249, alpha: 1)))
                                .cornerRadius(10)
                        })
                    }
                }.padding(.leading).padding(.trailing).frame(height: 50)
                Divider().padding(.leading).padding(.trailing)
                
                List {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track).gesture(LongPressGesture().onEnded({ _ in
                            self.showAlert = true
                            self.track = track
                        }).simultaneously(with: TapGesture().onEnded({ _ in
                            self.settrackDetailViewDelegate()
                            self.track = track
                            self.tabBarDelegate?.maximizeTrackDetailController(viewModel: self.track)
                        })))
                    }.onDelete(perform: delete)
                }.listStyle(PlainListStyle())
            }
            .actionSheet(isPresented: $showAlert, content: {
                ActionSheet(title: Text("Delete track: \(self.track.trackName)?"), buttons: [
                    .destructive(Text("Delete"), action: {
                        self.delete(track: self.track)
                    }),
                    .cancel()
                ])
            })
            .navigationBarTitle("Library", displayMode: .large)
        }
    }
    
    func delete(at offset: IndexSet) {
        tracks.remove(atOffsets: offset)
        
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    func delete(track: SearchViewModel.Cell) {
        guard let index = tracks.firstIndex(of: track) else { return }
        tracks.remove(at: index)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    func settrackDetailViewDelegate() {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?.windows
            .filter({ $0.isKeyWindow }).first
        let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
        tabBarVC?.trackDetailView.delegate = self
    }
}

struct LibraryCell: View {
    
    let cell: SearchViewModel.Cell
    
    var body: some View {
        HStack {
            URLImage(url: URL(string: cell.iconUrlString ?? "")!) { image in
                image
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(2)
            }
            VStack(alignment: .leading) {
                Text(cell.trackName)
                Text(cell.artistName)
            }
        }
    }
}

struct Library_Previews: PreviewProvider {
    
    static var previews: some View {
        Library()
    }
}

extension Library: TrackMovingDelegate {
    func moveBackForPreviouseTrack() -> SearchViewModel.Cell? {
        guard let index = tracks.firstIndex(of: track) else { return nil }
        var nextTrack: SearchViewModel.Cell
        if index - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[index - 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    func moveForwardForPreviouseTrack() -> SearchViewModel.Cell? {
        guard let index = tracks.firstIndex(of: track) else { return nil }
        var nextTrack: SearchViewModel.Cell
        if index + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[index + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
}
