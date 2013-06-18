#
#  AppDelegate.rb
#  FlashCardGenerator
#
#  Created by Ilya Pozdneev on 6/18/13.
#  Copyright 2013 Ilya Pozdneev. All rights reserved.
#

class AppDelegate
    attr_accessor :window, :slider, :document, :card, :card_name, :global_count
    def applicationDidFinishLaunching(a_notification)
        # Insert code here to initialize your application
    end
    
    def awakeFromNib
        @data = []
        @flashCards = []
    end
    
    def read(sender)
        dialog = NSOpenPanel.openPanel
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModalForDirectory(nil, file:nil) == NSOKButton
            path = dialog.filenames.first
            
            if path.pathExtension != "txt"
                alert = NSAlert.alertWithMessageText("Error", defaultButton:"OK", alternateButton:nil, otherButton:nil, informativeTextWithFormat:"Choose a .txt file")
                alert.runModal()
                
                read(true)
                return
            end
            
            display(path)
        end
    end
    
    def display(path)
        @lines = File.open(path).read
        @document.stringValue = @lines
        @lines.gsub!(/\r\n?/, "\n")
        @lines.each_line do |line|
            if line.include? "("
                @data.push(line)
            else
                next
            end
        end
        #puts "#{@data.length} #{@data} ######################"
    end
    
    def generateAFlashCard(sender)
        @flashCardSize = @slider.intValue
        @aFlashCard = []
        @flashCardSize.times do
            index = rand(@data.length - 1)
            @aFlashCard.push(@data[index])
            @data.delete_at(index)
        end
        @card.stringValue = @aFlashCard.to_s
        #puts "#{@aFlashCard.length} #{@aFlashCard} #{@data.length}"
    end
    
    def addCardToStack(sender)
        @flashCards.push(@aFlashCard)
        @global_count.stringValue = "Generated #{@flashCards.length} cards"
    end
    
    def exportCard(sender)
        name = @card_name.stringValue
        
        dialog = NSOpenPanel.openPanel
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        dialog.allowsMultipleSelection = false
        
        if dialog.runModalForDirectory(nil, file:nil) == NSOKButton
            path = dialog.filenames.first
        end
            
        path = path.to_s + "/" + name.to_s
        
        if @flashCards.length == 1
            if !path.include? ".txt"
                path = path + ".txt"
            end
            aCard = File.new(path, "w")
            @aFlashCard.each do |item|
                aCard.write(item)
            end
            aCard.close
            alert_success
            return
        else
            @flashCards.each_with_index do |item, index|
                new_path = path + index.to_s
                if !new_path.include? ".txt"
                    new_path = new_path + ".txt"
                end
                aCard = File.new(new_path, "w")
                item.each do |line|
                    aCard.write(line)
                end
                aCard.close
            end
        end
        alert_success
    end
    
    def alert_success
        alert = NSAlert.alertWithMessageText("Success", defaultButton:"OK", alternateButton:nil, otherButton:nil, informativeTextWithFormat:"Successfully Created #{@flashCards.length} FlashCards")
        alert.runModal()
    end
end

