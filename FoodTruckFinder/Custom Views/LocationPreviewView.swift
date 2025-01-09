//
//  LocationPreviewView.swift
//  SwiftfulMapApp
//
//  Created by Nick Sarno on 11/28/21.
//

import SwiftUI

struct LocationPreviewView: View {
    
    @Binding var viewModel: MapView.ViewModel
    
    let item: FoodTruckListItem
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                imageSection
                titleSection
            }
            
            VStack(spacing: 8) {
                learnMoreButton
                nextButton
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(10)
    }
}

extension LocationPreviewView {
    
    private var imageSection: some View {
        ZStack {
            if let imageUrlString = item.imageUrl,
               let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 75, height: 75)
                        .cornerRadius(12)
                } placeholder: {
                    ProgressView()
                        .frame(width: 75, height: 75)
                }
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(item.description)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var learnMoreButton: some View {
        Button {
            viewModel.detailButtonPressed()
        } label: {
            Text("Details")
                .font(.headline)
                .frame(width: 100, height: 35)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var nextButton: some View {
        Button {
            viewModel.nextButtonPressed()
        } label: {
            Text("Next")
                .font(.headline)
                .frame(width: 100, height: 35)
        }
        .buttonStyle(.bordered)
    }
    
}
