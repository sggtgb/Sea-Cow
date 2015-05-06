//
//  SwipeCardsViewBackground.swift
//  seaCow
//
//  Created by Liuyuan Tan on 4/20/15.
//  Copyright (c) 2015 Liuyuan Tan. All rights reserved.
//

import Foundation
import UIKit

// A set of constant and variable strings for making up the URL for article searching using NYT's API
let articleSearchBaseUrl = "http://api.nytimes.com/svc/mostpopular/v2"
let articleSearchResourceType = "mostviewed" // mostemailed | mostshared | mostviewed
let articleSearchSections = "all-sections"
let articlesSearchNumOfDays = 1 // 1 | 7 | 30
let articleSearchReturnFormat = ".json"
let articleSearchAPIKey = "b772e34fc2a53d05fe60d6c63d0c0e4c:9:71573042"

class SwipeCardsViewBackground: UIView {
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let MAX_CARD_NUM = 2 // maximum number of cards loaded at any given time, must be greater than 1
    let CARD_HEIGHT: CGFloat = UIScreen.mainScreen().bounds.size.height * 0.8
    let CARD_WIDTH: CGFloat = UIScreen.mainScreen().bounds.size.width * 0.85
    
    var loaded: Int = 0 // number of cards loaded
    var deck = [SwipeCardsView]() // array of loaded cards
    
    /*var settingsButton: UIButton
    var readingListButton: UIButton
    var yesButton: UIButton
    var noButton: UIButton*/
    
    var allCards = [SwipeCardsView]() // array of all cards
    
    var nytArticles = NYTArticles()
    var articleRequest: NSURLRequest?
    var selectedArticle: ArticleData?
    var toReadingList: [ArticleData] = []
    var done = false
    
    override init(frame: CGRect) {
        
        /*settingsButton = UIButton()
        readingListButton = UIButton()
        yesButton = UIButton()
        noButton = UIButton()*/
        super.init(frame:frame)
        self.setupView()
        var stringTitles: [String] = []
        // Make up search url
        var articleSearchUrl = articleSearchBaseUrl + "/" + articleSearchResourceType + "/" + articleSearchSections + "/" + "\(articlesSearchNumOfDays)" + articleSearchReturnFormat + "?" + "&API-Key=" + articleSearchAPIKey
        
        // load articles from the NYT API
        nytArticles.load(articleSearchUrl, loadCompletionHandler: {
            (nytArticles, errorString) -> Void in
            if let unwrappedErrorString = errorString {
                println(unwrappedErrorString)
            } else {
                for article in nytArticles.articles {
                    var card = SwipeCardsView()
                    card.label.text = article.title
                    card.articleData = article
                    if let imageUrl = NSURL(string: card.articleData.imageUrl) {
                        if let imageData = NSData(contentsOfURL: imageUrl){
                            card.backgroundView = UIImageView(image: UIImage(data: imageData)!)
                            println("Background view done")
                        }
                    }
                    self.allCards.append(card)
                }
                println("Total number of cards:\(self.allCards.count)")
                self.loaded = 0
                self.loadCards()
            }
        })
    }
    
    func setupView() {
        
        self.backgroundColor = UIColor.whiteColor()
    }
    
    func loadCards() {
        
        if allCards.count > 0 {
            // make sure max card load is smaller than actual deck size
            var numLoadedCardsCap = allCards.count > MAX_CARD_NUM ? MAX_CARD_NUM : allCards.count
            
            // loop through the exampleCardsLabels array to create a card for each label. This should be customerized by removing "exampleCardLabels" with another array of data
            for var i = 0 ; i < allCards.count; i++ {
                var newCard: SwipeCardsView = self.createSwipeCardsViewWithDataAtIndex(i)
                
                if i < numLoadedCardsCap {
                    // add some extra cards to be loaded
                    deck.append(newCard)
                }
            }
        }
        
        // display extra loaded cards
        for var i = 0; i < deck.count; i++ {
            if i > 0 {
                self.insertSubview(deck[i] as UIView, belowSubview: deck[i-1] as UIView)
            } else {
                self.addSubview(deck[i] as UIView)
            }
            loaded++
        }
        println("Number of cards loaded: \(loaded)")
    }
    var swiped: Int = 0
    func cardSwipedAway(card: UIView, direction: String) {
        swiped++
        let article: ArticleData = deck[0].articleData
        deck.removeAtIndex(0)
        println("Card swiped away")
        if(direction == "right") {
            println("Saving to reading list array")
            toReadingList.append(article)
        }
        // if all cards haven't been gone through, load another card into the deck
        if loaded < allCards.count {
            var newCard: SwipeCardsView = createSwipeCardsViewWithDataAtIndex(loaded)
            deck.append(newCard)
            //deck.append(allCards[loaded])
            loaded++
            self.insertSubview(deck[MAX_CARD_NUM-1] as UIView, belowSubview: deck[MAX_CARD_NUM-2] as UIView)
        }
        if(swiped == allCards.count) {
            println("Last card has been swiped")
            println(toReadingList.count)
            //try to segue to the reading list here.
            done = true
        }
    }
    
    func swipeRight() {
        var cardView: SwipeCardsView = deck.first!
        cardView.overlayView.mode = OverlayViewMode.OverlayViewRight
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            cardView.overlayView.alpha = 1
        })
        cardSwipedAway(cardView, direction: "right")
    }
    
    func swipeLeft() {
        var cardView: SwipeCardsView = deck.first!
        cardView.overlayView.mode = OverlayViewMode.OverlayViewLeft
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            cardView.overlayView.alpha = 1
        })
        cardSwipedAway(cardView, direction: "left")
    }
    
    func createSwipeCardsViewWithDataAtIndex(index: Int) -> SwipeCardsView {
        var swipeCardsView: SwipeCardsView = SwipeCardsView(frame: CGRectMake((self.frame.size.width - CARD_WIDTH) / 2, (self.frame.size.height - CARD_HEIGHT) / 2, CARD_WIDTH, CARD_HEIGHT))
        swipeCardsView.articleData = allCards[index].articleData
        swipeCardsView.backgroundView = allCards[index].backgroundView
        swipeCardsView.backgroundView.contentMode = UIViewContentMode.ScaleAspectFill
        swipeCardsView.label.text = allCards[index].label.text
        return swipeCardsView
    }
    
    func test() {
        println("allo")
    }
    
}
