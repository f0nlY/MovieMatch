//
//  ImageCropView.swift
//  MovieMatch
//
//  Created by Ilya on 31.05.2026.
//

import SwiftUI

struct ImageCropView: View {
    let image: UIImage
    var onCrop: (UIImage) -> Void
    var onCancel: () -> Void

    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    private let circleSize: CGFloat = 280
    private let minPixelSize: CGFloat = 100

    private var isCropValid: Bool {
        let screenW = UIScreen.main.bounds.width
        let imageSize = image.size
        let imageRatio = imageSize.width / imageSize.height

        let displayW = imageRatio > 1.0 ? screenW * imageRatio : screenW
        let scaledW = displayW * scale
        
        let currentPixelSize = (circleSize / scaledW) * imageSize.width
        return currentPixelSize >= minPixelSize
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { onCancel() } label: {
                        Text("Отмена")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    Spacer()
                    Text("Выбери область")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Button {
                        let cropped = cropImage()
                        onCrop(cropped)
                    } label: {
                        Text("Готово")
                            .foregroundColor(isCropValid ? .myRed : .gray.opacity(0.5))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .disabled(!isCropValid)
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 20)

                Spacer()

                ZStack {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(offset)
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .contentShape(Rectangle())
                    .gesture(
                        SimultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                .onEnded { _ in lastOffset = offset },

                            MagnificationGesture()
                                .onChanged { value in
                                        scale = max(1.0, lastScale * value)
                                    }
                                .onEnded { _ in lastScale = scale }
                        )
                    )
                    .clipped()

                    Rectangle()
                        .fill(Color.black.opacity(0.55))
                        .frame(width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.width)
                        .mask(
                            Rectangle()
                                .frame(width: UIScreen.main.bounds.width,
                                       height: UIScreen.main.bounds.width)
                                .overlay(
                                    Circle()
                                        .frame(width: circleSize, height: circleSize)
                                        .blendMode(.destinationOut)
                                )
                                .compositingGroup()
                        )
                        .allowsHitTesting(false)

                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: circleSize, height: circleSize)
                        .allowsHitTesting(false)

                    Circle()
                        .frame(width: circleSize, height: circleSize)
                        .overlay(
                            ZStack {
                                VStack(spacing: circleSize / 3) {
                                    Divider().background(Color.white.opacity(0.4))
                                    Divider().background(Color.white.opacity(0.4))
                                }
                                HStack(spacing: circleSize / 3) {
                                    Divider().background(Color.white.opacity(0.4))
                                    Divider().background(Color.white.opacity(0.4))
                                }
                            }
                            .clipShape(Circle())
                        )
                        .foregroundColor(.clear)
                        .allowsHitTesting(false)
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)

                Spacer()

                Text(isCropValid ? "Двигай и масштабируй двумя пальцами" : "Слишком мелкое разрешение (нужно минимум \(Int(minPixelSize))x\(Int(minPixelSize)) px)")
                    .foregroundColor(isCropValid ? .gray : .red)
                    .font(.system(size: 13))
                    .animation(.easeInOut, value: isCropValid)
                    .padding(.bottom, 40)
            }
        }
    }

    private func cropImage() -> UIImage {
        let screenW = UIScreen.main.bounds.width
        let imageSize = image.size

        let displayW: CGFloat
        let displayH: CGFloat

        let screenRatio = screenW / screenW
        let imageRatio = imageSize.width / imageSize.height

        if imageRatio > screenRatio {
            displayH = screenW
            displayW = screenW * imageRatio
        } else {
            displayW = screenW
            displayH = screenW / imageRatio
        }

        let scaledW = displayW * scale
        let scaledH = displayH * scale

        let centerX = scaledW / 2 - offset.width
        let centerY = scaledH / 2 - offset.height

        let circleInImage = (circleSize / scaledW) * imageSize.width

        let originX = (centerX / scaledW) * imageSize.width - circleInImage / 2
        let originY = (centerY / scaledH) * imageSize.height - circleInImage / 2

        let cropRect = CGRect(
            x: max(0, originX),
            y: max(0, originY),
            width: circleInImage,
            height: circleInImage
        )

        if let cgImage = image.cgImage,
           let cropped = cgImage.cropping(to: cropRect) {
            return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }
}
