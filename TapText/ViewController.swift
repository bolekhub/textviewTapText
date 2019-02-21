
/*
 Copyright 2019 Boris Chirino
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
 EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import AVFoundation

fileprivate let kUntappedSentenceFont: CGFloat = 22

class ViewController: UIViewController {

    private var attrString: NSMutableAttributedString = NSMutableAttributedString()

    /// the url to the audio file.
    private var tickUrl: URL? {
        get {
            let bundle = Bundle.main
            return bundle.url(forResource: "tick", withExtension: "m4a")
        }
    }

    /// Audio player object, url is optional. Force try because i´m the master of universe 😜
    private lazy var player: AVAudioPlayer? = {
        guard let fileUrl = self.tickUrl else { return nil }
        let plyr = try! AVAudioPlayer(contentsOf: fileUrl,
                                    fileTypeHint: AVFileType.m4a.rawValue)
        return plyr
    }()

    /// Attributes for all sentences initially
    private let linkAttributes: [NSAttributedString.Key : Any] = [
        .font : UIFont.systemFont(ofSize: kUntappedSentenceFont, weight: .medium ),
        .foregroundColor : UIColor.black,
        .underlineColor : UIColor.clear
    ]

    /// attributes when tapped
    private let tapLinkAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: UIColor.red,
        .underlineColor: UIColor.lightGray,
        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    /// the phrases
    private let phrasesArray: [String] = ["Roses 🌹 are red, violets  are blue. ",
                                          "A fool and his money are soon parted, ",
                                          "A journey of a thousand miles begins with a single step.",
                                          "All things come to those who wait"]

    @IBOutlet weak var textView: UITextView!

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.player?.prepareToPlay()
        textView.isSelectable = true
        textView.isEditable = false
        self.prepareStrings()
    }
}

//MARK: - private methods
private extension ViewController {

    func prepareStrings() {
        textView.text = ""
        attrString = NSMutableAttributedString(string: phrasesArray.joined())
        var i = 0 //index of the phrases as string, included on the link attribute
        for phrase in phrasesArray {

            let attr: [NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: kUntappedSentenceFont, weight: .light ),
                .foregroundColor : UIColor.black,
                .underlineColor : UIColor.clear,
                .link : "\(i)"
            ]
            let range = attrString.mutableString.range(of: phrase)
            attrString.addAttributes(attr, range: range)
            i += 1
        }
        textView.attributedText = attrString
        textView.linkTextAttributes = linkAttributes
        textView.delegate = self
    }
}

//MARK: - UITextViewDelegate
extension ViewController: UITextViewDelegate {
    /*
     1 - here we´ve the main trick. The URL parameter contain de index of the phrase in the phrases array.
     so if the proccess succeed obtaining the url, play the sound async on the mainQueue because even we invoque prepareToPlay, the first time the sound is played it take a long

     2 - Create a mutable attributed string from the original one

     3 - Remove the link attribute for that range ( so we can change de color )

     4 - Add the desired attribute to show selected sentence

     5 - Assign al changes to textview attributedText property. This also have some magic: when you assign again this property, previous links are restored when on previous tap were removed, got it ? 😲
     */

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {

        //1
        if let phrasesIndex = Int(URL.absoluteString) {
            print("Tapped on : \(phrasesArray[phrasesIndex])")
            DispatchQueue.main.async {
                self.player?.play()
            }
        } else {
            return false
        }
        //2
        let str = NSMutableAttributedString(attributedString: attrString)
        //3
        str.removeAttribute(NSAttributedString.Key.link, range: characterRange)
        //4
        str.addAttributes(tapLinkAttributes, range: characterRange)
        //5
        self.textView.attributedText = str
        //6
        return true
    }
}


