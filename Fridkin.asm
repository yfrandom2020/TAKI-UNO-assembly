; By: Yonathan Fridkin
; Date: 11.6.2022
; This is the TAKI game
; Enjoy :)
IDEAL
MODEL small
stack 100h
p386
DATASEG
GlobalArr db 11, 11, 12, 12, 13, 13, 14, 14, 21, 21, 22, 22, 23, 23, 24, 24, 31, 31, 32, 32, 33, 33, 34, 34, 41, 41, 42, 42, 43, 43, 44, 44, 51, 51, 52, 52, 53, 53, 54, 54, 61, 61, 62, 62, 63, 63, 64, 64, 71, 71, 72, 72, 73, 73, 74, 74, 81, 81, 82, 82, 83, 83, 84, 84, 91, 91, 92, 92, 93, 93, 94, 94, 101, 101, 102, 102, 103, 103, 104, 104, 111, 111, 112, 112, 113, 113, 114, 114, 121, 121, 122, 122, 123, 123, 124, 124, -11, -11, -12, -12, -13, -13, -14, -14, -2,-2, -2, -2, -3, -3, -41, -41, -42, -42, -43, -43, -44, -44 ; This is the main pile of cards. The value and color map in whatsapp.
Global_arr_size dw 117 ; last index of card - size is 118
Player1 db 100 dup(0) ; first hand - size is more than will probably be used - this way there is no need to combine arrays
Player1Size dw 0 ; current hand size of player - it determines the index to begin adding cards from
Player2 db 100 dup(0) ; second hand - size is more than will probably be used - this way there is no need to combine arrays
Player2Size dw 0 ; current hand size of player - it determines the index to begin adding cards from
Check_Play dw 1 ;  this is a variable to determine if the game is running. While it equals 1 the game runs and when it is zero the game ends
Play_direction dw 1 ; this is a variable to determine the play direction. 1 is normal direction and in order to reverse to mul by -1
Player_Turn dw 0 ; this is a variable to determine who's turn is it. At the end of each turn it is incresed by Play_direction. 

Draw_Two dw 0 ; this is a variable for the draw two condition
Last_Color db 0 ; this is a variable that describes the color of the last played card. They are the same as the card on top of discard pile but for easier access are also defined
Last_Value db 0 ; this is a variable that describes the color of the last played card. They are the same as the card on top of discard pile but for easier access are also defined
Drawn_Last_Turn db 0 ; a variable to determine if a card was drawn - if it was and last card is plus two, skip it

DiscardPile db 100 dup(0) ; the discard pile - cards played are moved to here - discard pile is larger than needed
Discard_Pile_Size dw 0 ; the discard pile size

Current_Index db ? ; this is a variable only used to determine the current index of press on card
Current_Value db ? ; this is a variable only used to store the value of the selected card, it doesn't analyse it's attributes.
Interval dw ? ; a variable to determine the distance between each card to another on screen
First_Round db 0 ; a boolean variable to determine if it's the first round in order to ignore +2 card
; Conventions: printing hand of players will always begin from X = 20 (it goes 9 back) and Y = 170 (it actually goes 15 back)
; The picture of draw pile will be printed from 70X50 (bottom left corner) to 100X100 (upper right corner)
; Discard pile will be in the middle of the screen (160X100)

Active_Special_Card_After_Taki db 0
Active_Special_Card_After_Super_Taki db 0 ; these are variables to determine if a special card was played after a taki or super taki, change color isn't included.


Last_Plus_Two db 0
; The following variables are picture related
stor   	 	dw      0      ;our memory location storage
imgHeight dw 200  ;Height of image that fits screen
imgWidth dw 320 ;Width of image that fits screen
adjustCX dw ?     ;Adjusts register CX
filename db 20 dup (?) ;Generates the file's name 
filehandle dw ?  ;Handles the file
Header db 54 dup (0)  ;Read BMP file header, 54 bytes
Palette db 256*4 dup (0)  ;Enable colors
ScrLine db 320 dup (0)   ;Screen Line
Errormsg db 'Error', 13, 10, '$'   ;In case of not having all the files, Error message pops
printAdd dw 0   ;Enable to add new graphics

RULE db 'TRULE.bmp', 0 ; picture of rules
OPEN db 'Topen.bmp', 0 ; picture of begin screen

Turn db 0

;---------------------------------------------------------------------------------
; sprites here
card1   db 0,0,0,0,0,0,0,1,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,1,1,1,1,0,0,0,0,0
		db 0,0,0,0,0,1,1,0,1,1,0,0,0,0,0
		db 0,0,0,0,1,1,0,0,1,1,0,0,0,0,0
		db 0,0,0,1,1,0,0,0,1,1,0,0,0,0,0
		db 0,0,1,1,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,1,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0 ; all value sprites are 16X15
		
card2   db 0,0,0,1,1,1,1,1,1,0,0,0,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,1,1,1,1,0,0,0,0,0
		db 0,0,0,0,1,1,1,1,0,0,0,0,0,0,0
		db 0,0,0,1,1,1,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,1,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1
		
card3   db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,1,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,1,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0

card4   db 0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,1,1,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0	

card5   db 0,0,0,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,0,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,0,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,0,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,0,0,0,0	
		
card6   db 0,0,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,1,1,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,1,1,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,1,1,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,1,1,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	
		
card7   db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,0,1,1,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		db 0,0,0,0,0,0,0,0,1,1,0,0,0,0,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,0
		db 0,0,0,0,0,1,1,0,0,0,0,0,0,0,0
		db 0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		db 0,1,1,0,0,0,0,0,0,0,0,0,0,0,0
		db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0

card8   db 0,0,0,1,1,1,1,1,1,1,1,1,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,1,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,0,0,0,0,0,1,1,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,1,0,0,0
		db 0,0,0,1,1,1,1,1,1,1,1,1,0,0,0

card9   db 0,0,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,1,1,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,0,1,1,1,1,1,1,1,1,1,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0

		
		
Blank_Card	db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0
			db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
			db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
			db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0 ; size is 31X19
		
cardplus db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
	 	 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		 db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
	 	 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0
		 db 0,0,0,0,0,0,1,1,0,0,0,0,0,0,0 ; this is the plus card

cardplus2 db 0,0,0,1,1,1,1,1,1,0,0,0,0,0,0
		  db 0,0,0,1,1,1,1,1,1,1,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,1,1,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,1,0,0
		  db 0,0,1,0,0,0,0,0,0,0,0,1,1,0,0
		  db 0,1,1,1,0,0,0,0,0,0,0,1,1,0,0
		  db 0,0,1,0,0,0,0,0,0,0,1,1,0,0,0
		  db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		  db 0,0,0,0,0,0,0,1,1,1,0,0,0,0,0
		  db 0,0,0,0,0,1,1,1,0,0,0,0,0,0,0
		  db 0,0,0,1,1,1,0,0,0,0,0,0,0,0,0
		  db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1
		  db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1
		

cardTAKI  db 1,1,1,1,1,1,1,1,0,0,1,1,0,0,0
		  db 1,1,1,1,1,1,1,1,0,1,0,0,1,0,0
		  db 0,0,0,1,1,0,0,0,0,1,0,0,1,0,0
		  db 0,0,0,1,1,0,0,0,1,1,1,1,1,1,0
		  db 0,0,0,1,1,0,0,0,1,0,0,0,0,1,0
		  db 0,0,0,1,1,0,0,1,0,0,0,0,0,0,1
		  db 0,0,0,1,1,0,0,1,0,0,0,0,0,0,1
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,1,1,0,0,1,1,0,0,0,1,1,0,0,0
		  db 0,1,1,0,1,1,0,0,0,0,1,1,0,0,0
		  db 0,1,1,1,1,0,0,0,0,0,1,1,0,0,0
		  db 0,1,1,1,0,0,0,0,0,0,1,1,0,0,0
		  db 0,1,1,1,1,0,0,0,0,0,1,1,0,0,0
		  db 0,1,1,0,1,1,0,0,0,0,1,1,0,0,0 ; this is the TAKI noraml card
		  db 0,1,1,0,0,1,1,0,0,0,1,1,0,0,0
		  
cardstop  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,1,1,1,0,0,0,0
		  db 0,0,0,0,1,1,1,0,1,1,1,0,0,0,1
		  db 1,1,1,0,1,1,1,0,1,1,1,0,0,1,1
		  db 1,1,1,0,1,1,1,0,1,1,1,0,1,1,1
		  db 1,1,1,0,1,1,1,0,1,1,1,0,1,1,1
		  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		  db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		  db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		  db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
		  db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0
		  db 0,0,0,0,1,1,1,1,1,1,1,1,0,0,0 ; this is the stop card
		  db 0,0,0,0,0,1,1,1,1,1,1,0,0,0,0		  


carddir   db 0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		  db 0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		  db 0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		  db 0,0,0,0,0,0,0,0,0,0,1,1,0,0,0
		  db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,1,0,0,0,0,0
		  db 0,0,0,0,0,1,0,0,0,0,0,0,0,0,0
		  db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0
		  db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		  db 0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		  db 0,1,1,1,1,1,1,1,1,1,1,1,1,0,0
		  db 0,0,1,1,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,1,1,0,0,0,0,0,0,0,0,0,0 ; this is the change direction card
		  db 0,0,0,0,0,1,0,0,0,0,0,0,0,0,0	

cardcolor db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,4,4,4,4,4,0,0,14,14,14,14,14,0,0
		  db 0,4,4,4,4,4,0,0,14,14,14,14,14,0,0
		  db 0,4,4,4,4,4,0,0,14,14,14,14,14,0,0
		  db 0,4,4,4,4,4,0,0,14,14,14,14,14,0,0
		  db 0,4,4,4,4,4,0,0,14,14,14,14,14,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,1,1,1,1,1,0,0,2,2,2,2,2,0,0
		  db 0,1,1,1,1,1,0,0,2,2,2,2,2,0,0
		  db 0,1,1,1,1,1,0,0,2,2,2,2,2,0,0
		  db 0,1,1,1,1,1,0,0,2,2,2,2,2,0,0
		  db 0,1,1,1,1,1,0,0,2,2,2,2,2,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ; this is the change color card, each square has it's own color and printing sprites with multiple colors has it's own function.	

cardsuper db 2,2,2,2,2,2,2,2,0,0,4,4,0,0,0
		  db 2,2,2,2,2,2,2,2,0,4,0,0,4,0,0
		  db 2,2,2,2,2,2,2,2,0,4,0,0,4,0,0
		  db 0,0,0,2,2,0,0,0,4,4,4,4,4,4,0
		  db 0,0,0,2,2,0,0,0,4,0,0,0,0,4,0
		  db 0,0,0,2,2,0,0,4,0,0,0,0,0,0,4
		  db 0,0,0,2,2,0,0,4,0,0,0,0,0,0,4
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		  db 14,14,0,0,0,0,0,0,0,1,1,0,0,0,0
		  db 14,14,0,0,14,0,0,0,0,1,1,0,0,0,0
		  db 14,14,0,14,0,0,0,0,0,1,1,0,0,0,0
		  db 14,14,14,0,0,0,0,0,0,1,1,0,0,0,0
		  db 14,14,0,14,0,0,0,0,0,1,1,0,0,0,0
		  db 14,14,0,0,14,0,0,0,0,1,1,0,0,0,0 ; this is the super taki card
		  db 14,14,0,0,0,14,0,0,0,1,1,0,0,0,0		

DRAWPILE db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0	
		 db 0,1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1,0	
		 db 1,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,4,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,5,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 1,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,1	
		 db 1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1	
		 db 0,1,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,1,0	
		 db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0			 


	
three   db 15, 15, 15, 6, 6
        db 6, 6, 6, 15, 6
        db 15, 15, 15, 6, 6
        db 6, 6, 6, 15, 6
        db 15, 15, 15, 6, 6

two        db 6, 30, 30, 30, 6
        db 30, 6, 6, 6, 30
        db 6, 6, 6, 30, 6
        db 6, 30, 30, 6, 6
        db 30, 30, 30, 30, 30
        
one        db 6, 40, 40, 40, 6
        db 6, 40, 40, 40, 6
        db 6, 6, 40, 40, 6
        db 6, 6, 40, 40, 6
        db 6, 6, 40, 40, 6		 
;---------------------------------------------------------------------------------

CODESEG
;------------------------------------------------------------------------------------------------------------------------------
; Function shuffles deck it receives - only used for shuffling global deck
; The function loops through the array. It randomizes an index and swaps the values between current index and randomized index
; In: Array offset and array count. 2 elements - 4 bytes
; Out: None
;------------------------------------------------------------------------------------------------------------------------------
proc shuffle_deck
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

	mov bx, [bp+6] ; array offset - functions like i in for loop in c#
	mov si, [bp+6] ; array offset in order to randomize indexes
	mov di, [bp+4] ; array count - 110
	mov dx, 0 ; count
	shuffle_loop:
		push dx
		mov dx, bx
		mov ax, 40h
		mov es, ax
		mov ax, [es:06ch]
		xor al, [byte cs:bx] ; random 
		
		mov bx, dx
		pop dx
		and al, 01110101b ; holds random index ( 0 - 117 )
		xor ah, ah
		
		mov ch, [bx] ; temp
		add si, ax ; si holds the random index
		mov cl, [si] ; actual random value from array
		mov [bx], cl
		mov [si], ch ; final result - switch between values of random index and [bx] index

		xor cx, cx
		inc bx
		mov si, [bp+6] ; reset to array offset
		inc dx
		cmp dx, di
		jb shuffle_loop ; loop

pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 4
endp shuffle_deck


;--------------------------------------------------------------------------------
; Function receives a sprite figure (not a card - a value)
; and prints it to screen in given location
; In: [bp+4] - sprite offset, [bp+6] - x cord
; [bp+8] - y cord, [bp+10] - color, [bp+12] - size of a line (constant)
; [bp+14] - number of lines (also constant)
; Out: Figure on screen
; The function creates the figure by looping through the array,
; ignoring elements with value of zero and lighting the pixel if current value is
; one, creating figure on screen.
;---------------------------------------------------------------------------------
proc Sprite_Figure 
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push es
push di
	
	mov ax, 0a000h
	mov es, ax
	xor ax, ax
	sub [bp+6], 7
	sub [bp+8], 8 ; result is 8 up and 7 left. Given cord is middle of the card
	mov di, [bp+6]
	
	mov si, [bp+4] ; sprite offset
	mov cx, [bp+14] ; number of lines	
	loop1:
		mov dx, [bp+12] ; size of one line
		loop2:
			push dx
			xor dx, dx
			cmp [byte ptr si], 0
			je continue
			
			print:
			mov bx, [bp+8] ; current row	
			
			mov ax, 320
			mul bx
			mov bx, ax ; calculation to get location of pixel on screen
			add bx, [bp+6] ; x
			
			mov ax, [bp+10] ; color
			mov [es:bx], al ; color location, es val is 0A000h
			
			continue:
			pop dx
			inc si ; next element in array	
			dec dx
			inc [bp+6] ; right by one
			
			cmp dx, 0
			jne loop2
		
		;mov ax, 320
		;sub ax, [bp+12] ; the size of one line
		;add [bp+6], ax ; new line
		inc [bp+8] ; one line down
		mov [bp+6], di ; reset x
		dec cx
		cmp cx, 0
		jne loop1
pop di
pop es
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 12
endp Sprite_Figure



;------------------------------------------------------------------
; Function plots a blank card on screen
; In: [bp+4] - card offset, [bp+6] - x pos
; [bp+8] - y pos, [bp+10] - color (it is a constant of 0)
; [bp+12] - size of one line ( constant), [bp+14] - number of lines
; Out: card on screen
;------------------------------------------------------------------- 
proc Card
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push es
push di
	
	mov ax, 0a000h
	mov es, ax
	xor ax, ax
	
	sub [bp+6], 9
	sub [bp+8], 15 ; result is 15 up and 9 left. Given cord is middle of the card
	mov di, [bp+6] ; orignal x
	
	mov si, [bp+4] ; sprite offset
	mov cx, [bp+14] ; number of lines	
	card_loop1:
		mov dx, [bp+12] ; size of one line
		card_loop2:
			push dx
			xor dx, dx
			cmp [byte ptr si], 0
			je card_continue
			
			card_print:
			mov bx, [bp+8] ; current row	
			
			mov ax, 320
			mul bx
			mov bx, ax ; calculation to get location of pixel on screen
			add bx, [bp+6] ; x
			
			mov ax, [bp+10] ; color
			mov [es:bx], al ; color location, es val is 0A000h
			
			card_continue:
			pop dx
			inc si ; next element in array	
			dec dx
			inc [bp+6] ; right by one
			
			cmp dx, 0
			ja card_loop2
		
		mov [bp+6], di ; reset line to original, and one line down
		inc [bp+8] ; one line down	
		dec cx
		cmp cx, 0
		ja card_loop1
pop di
pop es
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 12
endp Card

;----------------------------------------------------------
; This function is exactly like
; Sprite_Figure: it receives the same parameters
; but here, each element in the sprite has it's own color.
;----------------------------------------------------------
proc Special_Sprite_Figure 
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di
push es
	
	mov ax, 0a000h
	mov es, ax
	xor ax, ax
	sub [bp+6], 7
	sub [bp+8], 8 ; result is 8 up and 7 left. Given cord is middle of the card
	mov di, [bp+6]
	mov si, [bp+4] ; sprite offset
	mov cx, [bp+12] ; number of lines	
	specialloop1:
		mov dx, [bp+10] ; size of one line
		specialloop2:
			push dx
			xor dx, dx
			cmp [byte ptr si], 0
			je specialcontinue
			
			specialprint:
			mov bx, [bp+8] ; current row	
			mov ax, 320
			mul bx
			mov bx, ax ; calculation to get location of pixel on screen
			add bx, [bp+6] ; x
			mov ax, [si] ; color
			mov [es:bx], al ; color location, es val is 0A000h
			
			specialcontinue:
			pop dx
			inc si ; next element in array	
			dec dx
			inc [bp+6] ; right by one
			cmp dx, 0
			jne specialloop2
		
		mov ax, 320
		sub ax, [bp+12] ; the size of one line
		mov [bp+6], di ; reset x
		inc [bp+8] ; one line down	
		dec cx
		cmp cx, 0
		jne specialloop1
pop es
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 10
endp Special_Sprite_Figure


;-----------------------------------------------------------------------------
; This is the show deck function. It shows a card and value on screen.
; For showing hands, the function will be called multiple times.
; In: number, color, x position and y position
; [bp+4] - card (color and val are extracted), [bp+6] - x pos, [bp+8] - y pos
; Out: card on screen in given location
; The function goes through all the different conditions of cards.
;-----------------------------------------------------------------------------
proc Show_Card
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push es

	mov ax, 0a000h
	mov es, ax
	xor ax, ax
	mov ax, [bp+4] ; card
	cmp ax, 124
	ja Special_Card
	
	Regular_Card:
		mov dh, 10
		div dh ; color is in ah, val in al
		
		cmp al, 1
		je Card_Is_One
		cmp al, 2
		je Card_Is_Two
		cmp al, 3
		je Card_Is_Three
		cmp al, 4
		je Card_Is_Four
		cmp al, 5
		je Card_Is_Five
		cmp al, 6
		je Card_Is_six
		cmp al, 7
		je Card_Is_Seven
		cmp al, 8
		je Card_Is_Eight
		cmp al, 9
		je Card_Is_Nine
		cmp al, 10
		je Card_Is_Stop
		cmp al, 11
		je Card_Is_dir
		cmp al, 12
		je Card_Is_Plus
		
	Special_Card:
		cmp ax, 0FEh ; check if change color card
		je Card_Change_Color
		cmp ax, 0FDh ; check if super TAKI
		je Card_Super_Taki ; find a solution for super taki
		; if reached card is special but has color. Can be a TAKI or a plus2
		cbw	
		mov dh, 10
		idiv dh ; al has val, ah has color. mul ah in -1 cuz it's still negative
		mov cx, ax ; save card with psuedo color. In cl there is val and in ch psudo color
		xor al, al ; no val 
		mov al, ah ; pseudo color
		xor ah, ah ; now only pseudo color in ax
		
		mov dh, -1
		imul dh ; color fixed saved in al?
		mov ah, cl ; val

		mov bx, ax
		mov ah, al
		mov al, bh
		xor bx,bx ; now ah has actual color and al has some special negative value
		
		mov bl, ah ; color
		mov cl, al ; val
		
		cmp cl, 0FFh ; check if it's a TAKI
		je Card_Taki
		
		cmp cl, 0FCh ; check if it a plus two
		je Card_Plus_Two
		
		jmp Finish_Show_Card
		
		; with this, all cases covered?
		
		Card_Is_One:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			; al holds val, ah holds color
			
			cmp ah, 1
			je red_one
			
			cmp ah, 2
			je blue_one
			
			cmp ah, 3
			je green_one
			
			cmp ah, 4
			je yellow_one
			jmp Finish_Show_Card
			
			red_one:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card1
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_one:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card1
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_one:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card1
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_one:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card1
			call Sprite_Figure
			jmp Finish_Show_Card
			
			
			
		Card_Is_Two:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_two
			
			cmp ah, 2
			je blue_two
			
			cmp ah, 3
			je green_two
			
			cmp ah, 4
			je yellow_two
			jmp Finish_Show_Card
			
			red_two:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card2
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_two:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card2
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_two:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card2
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_two:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card2
			call Sprite_Figure
			jmp Finish_Show_Card	
		
		Card_Is_Three:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_three
			
			cmp ah, 2
			je blue_three
			
			cmp ah, 3
			je green_three
			
			cmp ah, 4
			je yellow_three
			jmp Finish_Show_Card
			
			red_three:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card3
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_three:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card3
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_three:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card3
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_three:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card3
			call Sprite_Figure
			jmp Finish_Show_Card
			
		Card_Is_Four:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_four	
			
			cmp ah, 2
			je blue_four	
			
			cmp ah, 3
			je green_four
			
			cmp ah, 4
			je yellow_four
			jmp Finish_Show_Card
			
			red_four:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card4
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_four:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card4
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_four:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card4
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_four:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card4
			call Sprite_Figure
			jmp Finish_Show_Card
				
		
		Card_Is_Five:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_five	
			
			cmp ah, 2
			je blue_five
			
			cmp ah, 3
			je green_five
			
			cmp ah, 4
			je yellow_five
			jmp Finish_Show_Card
			
			red_five:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card5
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_five:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card5
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_five:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card5
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_five:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card5
			call Sprite_Figure
			jmp Finish_Show_Card

		Card_Is_six:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_six
			
			cmp ah, 2
			je blue_six
			
			cmp ah, 3
			je green_six
			
			cmp ah, 4
			je yellow_six
			jmp Finish_Show_Card
			
			red_six:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card6
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_six:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card6
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_six:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card6
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_six:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card6
			call Sprite_Figure
			jmp Finish_Show_Card

		Card_Is_Seven:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_seven
			
			cmp ah, 2
			je blue_seven
			
			cmp ah, 3
			je green_seven
			
			cmp ah, 4
			je yellow_seven
			jmp Finish_Show_Card
			
			red_seven:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card7
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_seven:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card7
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_seven:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card7
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_seven:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card7
			call Sprite_Figure
			jmp Finish_Show_Card
		
		Card_Is_Eight:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_eight
			
			cmp ah, 2
			je blue_eight
			
			cmp ah, 3
			je green_eight
			
			cmp ah, 4
			je yellow_eight
			jmp Finish_Show_Card
			
			red_eight:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card8
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_eight:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card8
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_eight:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card8
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_eight:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card8
			call Sprite_Figure
			jmp Finish_Show_Card
		
		Card_Is_Nine:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_nine
			
			cmp ah, 2
			je blue_nine
			
			cmp ah, 3
			je green_nine
			
			cmp ah, 4
			je yellow_nine
			jmp Finish_Show_Card
			
			red_nine:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card9
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_nine:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card9
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_nine:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card9
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_nine:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset card9
			call Sprite_Figure
			jmp Finish_Show_Card

		Card_Is_Stop:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_stop
			
			cmp ah, 2
			je blue_stop
			
			cmp ah, 3
			je green_stop	
			
			cmp ah, 4
			je yellow_stop	
			jmp Finish_Show_Card
			
			red_stop:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardstop
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_stop:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardstop
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_stop:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardstop
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_stop:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardstop
			call Sprite_Figure
			jmp Finish_Show_Card

		Card_Is_dir:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_dir
			
			cmp ah, 2
			je blue_dir
			
			cmp ah, 3
			je green_dir	
			
			cmp ah, 4
			je yellow_dir
			jmp Finish_Show_Card
			
			red_dir:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset carddir
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_dir:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset carddir
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_dir:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset carddir
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_dir:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset carddir
			call Sprite_Figure
			jmp Finish_Show_Card	

		Card_Is_Plus:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_plus
			
			cmp ah, 2
			je blue_plus
			
			cmp ah, 3
			je green_plus	
			
			cmp ah, 4
			je yellow_plus
			jmp Finish_Show_Card
			
			red_plus:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_plus:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_plus:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_plus:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus
			call Sprite_Figure
			jmp Finish_Show_Card			

		Card_Taki:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_taki
			
			cmp ah, 2
			je blue_taki
			
			cmp ah, 3
			je green_taki	
			
			cmp ah, 4
			je yellow_taki
			jmp Finish_Show_Card
			
			red_taki:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardTAKI
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_taki:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardTAKI
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_taki:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardTAKI
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_taki:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardTAKI
			call Sprite_Figure
			jmp Finish_Show_Card
			
		Card_Change_Color:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			push 16 ; amount of lines
			push 15 ; length of each line
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardcolor
			call Special_Sprite_Figure
			
			jmp Finish_Show_Card	
			
		
		Card_Super_Taki:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			push 16 ; amount of lines
			push 15 ; length of each line
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardsuper
			call Special_Sprite_Figure
			
			jmp Finish_Show_Card

		Card_Plus_Two:
			
			push 31 ; amount of lines
			push 19 ; length of each line
			push 15 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset Blank_Card
			call Card
			
			cmp ah, 1
			je red_plus2
			
			cmp ah, 2
			je blue_plus2
			
			cmp ah, 3
			je green_plus2	
			
			cmp ah, 4
			je yellow_plus2
			jmp Finish_Show_Card
			
			red_plus2:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 4 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus2
			call Sprite_Figure
			jmp Finish_Show_Card
			
			blue_plus2:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 1 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus2
			call Sprite_Figure
			jmp Finish_Show_Card
			
			green_plus2:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 2 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus2
			call Sprite_Figure
			jmp Finish_Show_Card
			
			yellow_plus2:
			push 16 ; amount of lines
			push 15 ; length of each line
			push 14 ; color
			push [word ptr bp+8] ; y
			push [word ptr bp+6] ; x
			push offset cardplus2
			call Sprite_Figure
			jmp Finish_Show_Card
			
			jmp Finish_Show_Card	
			
		

Finish_Show_Card:
pop es
pop dx
pop cx
pop bx
pop ax
pop bp
ret 6
endp Show_Card


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function draws cards for player by copying elements from main array to the hand. It goes through the array for the amount of cards given and takes out the elemnts.
; In: main array offset, main array length (constant of 118), amount to draw, hand offset , hand current size - total of 5 elements - 10 bytes
; Out: none - only fills the array with values, they are 0's at the beggining
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc DrawXCards
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

	mov bx, [bp+4] ; main array offset
	mov cx, 0 ; count for finding index to begin copying values from
	mov si, [bp+6] ; main array size offset 
	add bx, 117 ; point to the last element
	sub bx, [si] ; with this bx points to the first card that is not zero
	mov dx, 118 ; max size of array
	find_index:
		cmp [byte ptr bx], 0
		jne index_found
		inc bx
		inc cx ; index
		cmp cx, dx ; cmp to 110
		jb find_index
		jmp finishsearching ; deck is empty in that case - impossible to draw
	index_found:
		add bx, cx
; now allocating begins from where values in main deck aren't zero	
allocation:
	mov cx, [bp+8]  ; cards to draw in cx
	xor ch, ch
	mov si, [bp+10] ; hand offset - now find index to begin adding from
	mov di, [bp+12] ; hand size offset
	add si, [di] ; current hand size - to know where to begin allocating from
		allocation_loop:
			mov al, [byte ptr bx]
			mov [si], al
			mov [byte ptr bx], 0
			inc si
			inc bx
			loop allocation_loop
	
	mov ax, [bp+8] ; how many cards were drawn
	add [di], ax ; change current hand size
	
	mov si, [bp+6]
	sub [si], ax ;  new amount of cards in main pile

finishsearching:
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 10
endp DrawXCards

proc Current_Turn ; display on screen the number of current player, 1 in red and 2 in blue
cmp [Player_Turn], 0
je Turn_Is_One
jmp Turn_Is_Two


Turn_Is_One:
push 16
push 15
push 4 ; color
push 15
push 15
push offset Card1
call Sprite_Figure
jmp End_Current_Turn

Turn_Is_Two:
push 16
push 15
push 1 ; color
push 15
push 15
push offset Card2
call Sprite_Figure

End_Current_Turn:
ret
endp Current_Turn


;---------------------------------------
; Function creates a delay of one second
; Used to reset the timer for random
; And the number's delay between turns.
; In: none
; Out: none
;---------------------------------------
proc WaitASecond
	mov ax, 40h
	mov es, ax
	mov ax, [es:6ch]
FirstTick:
	cmp ax, [es: 6ch]
	je FirstTick
	mov cx, 19
DelayLoop:
	mov ax, [es:6ch]
Tick:
	cmp ax, [es:6ch]
	je Tick
	loop DelayLoop
	ret
endp WaitASecond


;------------------------------------------------------------------------------------------------------------------------
; This function checks if a click on mouse was in the range of a card
; It does that by first checking the y of click is in range and then iterating through each card and checking if the x
; was in it's range
; In: [bp+4] - x, [bp+6] - y, [bp+8] - interval between cards ( constant between each card to another)
; Out: 5 in cx if press in card and 4 if not.
;-------------------------------------------------------------------------------------------------------------------------
proc Is_On_Card
push bp
mov bp, sp
push bx
push cx
push dx
push di
push si

	mov dx, [bp+4] ; the x cordinate
	mov cx, [bp+6] ; y cordinate
	mov ax, [bp+8] ; the interval
	mov di, 11 ; the first left bound
	mov si, 29 ; the first right bound
	
	; first check that y is in card range
	cmp cx, 155
	jae Upper_True
	jmp Is_On_Card_Done ; press was too high
	Upper_True:
		cmp cx, 185
		jbe Lower_True ; press was too low
		jmp Is_On_Card_Done
		; now check for x position
		Lower_True:
			; now check if dx is between each of the cards
			Check_For_Each_Card:
			cmp si, 320
			jbe Continue_Current_Check ; max wasn't reached
			jmp Is_On_Card_Done ; out of check range
			
			Continue_Current_Check:
			cmp dx, di
			jae Left_Bound_Right
			jmp Is_On_Card_Done ; out of bound
			Left_Bound_Right:
				cmp dx, si
				jbe Indeed_Card ; if click is between left bound and right bound of card
				jmp Next_Card_Iteration ; not in bounds	
			Next_Card_Iteration:
			add di, 18 ; the length of one card
			add di, ax ; interval
			
			add si, ax ; the interval
			add si, 18 ; set boundaries to those of the next card
			jmp Check_For_Each_Card
			
			; if end of loop reached, press was not a card	
	Indeed_Card:
		mov ax, 0FFFFh
		jmp Is_On_Card_Done
Is_On_Card_Done:
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop bp
	ret 6
endp Is_On_Card


;----------------------------------------------------------------------------------
; The following function shows the mouse and limits it's range to the screen range
; In: none
; Out: none
;----------------------------------------------------------------------------------
proc Mouse
push ax


	
	mov ax, 1
	int 33h ; show mouse
	

pop ax
ret
endp Mouse

proc Initialize_Mouse
push ax
	mov ax, 0
	int 33h
pop ax
ret
endp Initialize_Mouse	

proc Limit_Mouse
push ax
push cx
push dx
	
	mov cx, 635
	mov dx, 0
	mov ax, 7
	int 33h ; limit mouse in X
	
	mov cx, 195
	mov dx, 0
	mov ax, 8
	int 33h ; limit mouse in Y
pop dx
pop cx
pop ax	
ret
endp Limit_Mouse



; The following procedures are picture related
;-------------------------------------------------------------------
;Prints the bmp file provided
;IN: ax - img offset, imgHeight (dw), imgWidth (dw), printAdd (dw)
;OUT: printed bmp file
proc PrintBmp
	push cx
	push di
	push si
	push cx
	push ax
	xor di, di
	mov di, ax
	mov si, offset filename
	mov cx, 20
Copy:
	mov al, [di]
	mov [si], al
	inc di
	inc si
	loop Copy
	pop ax
	pop cx
	pop si
	pop di
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitMap
	call CloseFile
	
	pop cx
	ret
endp PrintBmp

;in proc PrintBmp
proc OpenFile
	mov ah,3Dh
	xor al,al ;for reading only
	mov dx, offset filename
	int 21h
	jc OpenError
	mov [filehandle],ax
	ret
OpenError:
	mov dx,offset Errormsg
	mov ah,9h
	int 21h
	ret
endp OpenFile

;in proc PrintBmp
proc ReadHeader
;Read BMP file header, 54 bytes
	mov ah,3Fh
	mov bx,[filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader

;in proc PrintBmp
proc ReadPalette
;Read BMP file color palette, 256 colors*4bytes for each (400h)
	mov ah,3Fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette

;in proc PrintBmp
proc CopyPal
; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h ;port of Graphics Card
	mov al,0 ;number of first color
	;Copy starting color to port 3C8h
	out dx,al
	;Copy palette itself to port 3C9h
	inc dx
PalLoop:
	;Note: Colors in a BMP file are saved as BGR values rather than RGB.	
	mov al,[si+2] ;get red value
	shr al,2 	; Max. is 255, but video palette maximal value is 63. Therefore dividing by 4
	out dx,al ;send it to port
	mov al,[si +1];get green value
	shr al,2
	out dx,al	;send it
	mov al,[si]
	shr al,2
	out dx,al 	;send it
	add si,4	;Point to next color (There is a null chr. after every color)
	loop PalLoop
	ret
endp CopyPal

;in proc PrintBmp
proc CopyBitMap
; BMP graphics are saved upside-down.
; Read the graphic line by line ([height] lines in VGA format),
; displaying the lines from bottom to top.
	mov ax,0A000h ;value of start of video memory
	mov es,ax	
	push ax
	push bx
	mov ax, [imgWidth]
	mov bx, 4
	div bl
	
	cmp ah, 0
	jne NotZero
Zero:
	mov [adjustCX], 0
	jmp Continueimg
NotZero:
	mov [adjustCX], 4
	xor bx, bx
    mov bl, ah
	sub [adjustCX], bx
Continueimg:
	pop bx
	pop ax
	mov cx, [imgHeight]	;reading the BMP data - upside down
	
PrintBMPLoop:
	push cx
	xor di, di
	push cx
	dec cx
	Multi:
		add di, 320
		loop Multi
	pop cx

    add di, [printAdd]
	mov ah, 3fh
	mov cx, [imgWidth]
	add cx, [adjustCX]
	mov dx, offset ScrLine
	int 21h
	;Copy one line into video memory
	cld	;clear direction flag - due to the use of rep
	mov cx, [imgWidth]
	mov si, offset ScrLine
	rep movsb 	;do cx times:
				;mov es:di,ds:si -- Copy single value form ScrLine to video memory
				;inc si --inc - because of cld
				;inc di --inc - because of cld
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitMap

;in proc PrintBmp
proc CloseFile
	mov ah,3Eh
	mov bx,[filehandle]
	int 21h
	ret
endp CloseFile
;---------------------------------------------------------------------------------------
; End of picture procedures

proc Open_Picture ; function displays the opening image of game
push ax

mov ax, offset OPEN ; image offset
mov [PrintAdd], 0
call PrintBmp

; now waiting for data
; if 1 is pressed, exit proc and return to start
; if 2 is pressed, jump to the rules
; in the rules proc you must press any key to go back to the first picture

Open_Picture_Data:
mov ah, 1
int 16h
jz Open_Picture_Data
mov ah, 0
int 16h
cmp ah, 2 ; 1 was pressed?
je End_Open_Picture ; and go to main game
cmp ah, 3 ; check for press on two
je Rules_Picture
jmp Open_Picture_Data


Rules_Picture:
call Rules
jmp Open_Picture_Data


End_Open_Picture:
pop ax
ret
endp Open_Picture


proc Rules ; function displays the rules picture on screen, exited only if enter is pressed
push ax

mov [PrintAdd], 0
mov ax, offset RULE ; offset rules picture
call PrintBmp

Wait_For_Rules_Escape:
mov ah, 1
int 16h
jz Wait_For_Rules_Escape
mov ah, 0
int 16h
cmp ah, 1 ; check escape
je Escape_Rules_Picture
jmp Wait_For_Rules_Escape

Escape_Rules_Picture:
mov ax, offset OPEN
mov [PrintAdd], 0
call PrintBmp
pop ax
ret
endp Rules


;-------------------------------------------------------------------------
; Function states if a card from hand is playable
; It does that by comapring the value and color of the card with the last 
; color and value aka [Last_Color] and [Last_Value]
; In: card from hand
; Out: 5 in cx if playable
;-------------------------------------------------------------------------
proc CanPlayCard
push bp
mov bp, sp
push ax
push bx	
push dx	
push si	
push di
	
	mov si, [bp+4] ; card offset
	mov al, [si] ; card from hand	
	xor ah, ah
	cmp al, -2 ; if card from hand is change color	
	je playable

	cmp al, -3 ; if card from hand is super TAKI
	je playable
	
	cmp al, 124 ; check wether a card is regular or not. For example, 4 red is normal, +2 is not.
	ja Hand_Special
	
	; now card from hand is not special
	
	mov dh, 10
	div dh ; color and val are extracted normaly: ah has color and al has val
	
	push ax
	mov ah, [Last_Color]
	mov al, [Last_Value]
	
	cmp al, 0FEh ; check for change color on discard pile
	je Compare_Hand_And_Color
	jmp not_change_color
	
	Compare_Hand_And_Color:
	pop ax ; return card from hand
	cmp ah, [Last_Color]
	je playable
	jmp Done_Checking
	
	not_change_color:
	; continue checking cases
	cmp al, 0FDh ; check for discard is special TAKI
	je playable
	
	; now cases of change color and super TAKI in discard while hand is normal are covered. ax has the val of discard now and it is not special
	mov cx, ax ; discard card
	pop ax
	cmp ah, ch
	je playable
	cmp al, cl
	je playable
	jmp Done_Checking ; can't be played
	
	Hand_Special:	
		cbw
		mov dh, 10
		idiv dh
		neg ah ; ah holds actual color of hand and al holds val
		
		mov cx, ax ; hand
		mov ah, [Last_Color] ; discard values
		mov al, [Last_Value]
		; now check if discard is first change color or taki and then other special card
		
		cmp ch, ah
		je playable
		
		cmp cl, al
		je playable
		jmp Done_Checking
		
playable:
mov cx, 5	
		
Done_Checking:
pop di
pop si
pop dx
pop bx
pop ax
pop bp
ret 2
endp CanPlayCard


;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Function plays card from hand
; Will only be called after the CanPlayCard function. It sets the last card on discard pile to the card value and takes out the card from hand, shifting the other cards left
; In: offset of card (index in hand), hand offset, offset hand current size, also Discard pile offset and discard pile size offset. Total of 5 elements - 10 bytes
; Out: none
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc PlayACard 
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

	mov bx, [bp+4] ; hand offset
	mov si, [bp+6] ; offset of card to play
	mov ax, [si] ; card val in ax but actually in al
	mov si, [bp+8] ; offset hand size
	mov dx, 0 ; count
	
	FindIndex: ; this is a loop to find the index in hand of the card to play
	cmp al, [bx]
	je Found_Card
	inc bx
	inc dx
	cmp dx, [si] ; check of reached hand current size
	jb FindIndex
; index of card to be played found now?	
	
Found_Card:
	mov di, [bp+10] ; Discard Pile offset
	push si
	mov si, [bp+12] ; discard size offset 
	add di, [si] ; actual size of discard pile
	pop si
	mov cl, [bx] ; the card to play
	mov [di], cl ; put card on top of discard Pile
	mov [byte ptr bx], 0
	
	mov si, bx ; index to begin with
	mov di, bx
	inc di ; next index
	mov dx, bx
	push si
	push bx 
	
	mov si, [bp+8]
	mov bx, [bp+4] ; hand offset
	add bx, [si]
	mov cx, bx ; index of last card in hand - aka hand size
	
	pop bx
	pop si
	
	; shift card from the right to fill the hole	
	shift_loop:
		mov al, [di]
		mov [si], al
		
		inc di
		inc si
		inc dx
		cmp dx, cx
		jb shift_loop ; the lines shift each value after the index of card to one left. 
	
	mov bx, [bp+4]
	mov si, [bp+8]
	add bx, [si]
	mov [byte ptr bx], 0 ; these lines put zero on the last element in the existing array since it loops until Length - 1
	
	mov si, [bp+8]
	dec [byte ptr si] ; decrease hand size by one
	
	mov si, [bp+12] ; offset hand size
	inc [byte ptr si] ; increase size of Discard pile size by one

pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 10	
endp PlayACard	


proc WaitForEnterKey ; function waits for enter key to be pressed on, used for changing turns
push ax
Wait_For_Enter:
	mov ah, 1
	int 16h
	jz Wait_For_Enter
	mov ah, 0
	int 16h
	cmp ah, 1ch
	jne Wait_For_Enter
pop ax
ret 
endp WaitForEnterKey		
;-----------------------------------
; Function switches to graphic mode
; In: None
; Out: None
;-----------------------------------
proc GraphicMode
push ax
	mov ax, 13h
	int 10h
pop ax
ret
endp GraphicMode


;-------------------------------------------------
; Function clears and prints again on screen
; The discard pile, last card played
; and hand
; Used after deck is updated 
; In: hand offset in si and offset hand size in bx
;--------------------------------------------------
proc Re_Show_Screen
push ax
push bx
push si
push di

	call Hide_Mouse
	call GraphicMode ; first reset screen
	call Print_Draw_Pile ; now print the discard pile
	
	push si ; save hand offset
	
	mov si, offset DiscardPile
	add si, [Discard_Pile_Size]
	dec si
	mov ax, [si]
	xor ah, ah
	push 100
	push 160
	push ax
	call Show_Card ; now show discard card in middle of screen
	
	pop si ; return hand offset 
	
	mov ax, [bx] ; actual amount of cards in hand
	; now show deck
	push 170
	push 20
	push ax
	push si
	call Visual_Deck ; show current deck
	mov [Interval], dx
	
	;call Initialize_Mouse
	call Mouse
	call Limit_Mouse
	call Current_Turn

pop di
pop si
pop bx
pop ax 
ret 
endp Re_Show_Screen	


	

proc Hide_Mouse
push ax
mov ax, 2
int 33h
pop ax
ret
endp Hide_Mouse
	
	

proc Sprite_Draw
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

	mov ax, 0a000h
	mov es, ax
	mov di, [bp+6] ; orignal x
	mov si, [bp+4] ; sprite offset
	mov cx, [bp+14] ; number of lines	
	Draw_loop1:
		mov dx, [bp+12] ; size of one line
		Draw_loop2:
			push dx
			xor dx, dx

			
			printDraw:
			
			mov bx, [bp+8] ; current row	
			
			mov ax, 320
			mul bx
			mov bx, ax ; calculation to get location of pixel on screen
			add bx, [bp+6] ; x
			
			mov ax, [si] ; color
			xor ah, ah
			cmp al, 1
			je White
			cmp al, 4
			je Red
			; cmp al, 9
			; je Blue	
			; jmp ColorIt
			
			White:
			mov al, 15
			jmp ColorIt
			Red:
			mov al, 4
			jmp ColorIt
			Blue:
			mov al, 1
			
			ColorIt:
			mov [es:bx], al ; color location, es val is 0A000h
			
			pop dx
			inc si ; next element in array	
			dec dx
			inc [byte ptr bp+6] ; right by one
			
			cmp dx, 0
			jne Draw_loop2
		
		mov [bp+6], di
		inc [bp+8]
		dec cx
		cmp cx, 0
		jne Draw_loop1
pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 12
endp Sprite_Draw	



proc Print_Draw_Pile
push 50
push 30
push 3
push 70
push 30
push offset DRAWPILE
call Sprite_Draw
ret 
endp Print_Draw_Pile	
;----------------------------------------------------------------------------------
; This function shows a deck on screen
; First, it calculates a constant interval between each card
; Then, it iterates throught the array and calls the function Show_Card.
; In: [bp+4] - array offset, [bp+6] - amount. [bp+8] - x to begin pixelating from.
; [bp+10] - y to begin pixelating from, a constant.
; Out: hand printed on screen in the given location
;----------------------------------------------------------------------------------
proc Visual_Deck ; resize sprite - understand intervalss
push bp
mov bp, sp
push ax
push bx
push cx
push si
push es
	
	mov ax, 0a000h ; set es to graphic memory
	mov es, ax
	xor ax, ax
	
	mov si, [bp+4] ; array offset
	mov cx, [bp+6] ; amount of cards, is actually in cl
	; doing calculations to receive pixel interval between cards. For examples if there are 6 cards ( the length of one line is 320 pixels) the total distance of cards is 300 hence intervals will be 20 / 6 between each.
	mov ax, 19
	mul cl ; now ax holds the amount of pixels the cards take
	mov dx, 320
	sub dx, [bp+8] ; begin x
	sub dx, ax ; the remaining pixels between start index and 320?
	mov ax, dx ; remaning pixels
	mov cx, [bp+6]
	cmp cx, 1
	je Only_One_Card
	dec cx ; between X cards there are X-1 intervals
	mov dx, 0
	div cx
	mov dx, ax
	jmp Continue_Showing_Deck
	
	Only_One_Card:
	mov dx, 0 ; interval is zero, there is only one card
	
	
	
	Continue_Showing_Deck:
	mov cx, [bp+6] ; amount of cards
	Show_Deck_Loop:
		
		push [bp+10] ; y
		push [bp+8] ; x
		mov ax, [si]
		xor ah, ah
		push ax ; card
		call Show_Card
		
		add [bp+8], 9 ; half a line - point x to the end of card, rightmost x of card
		add [bp+8], dx ; now add interval
		add [bp+8], 9 ; mov x to middle row, since creating a card goes 9 back
		
		
		inc si ; one elemnt nexts
		loop Show_Deck_Loop
	
pop es
pop si
pop cx
pop bx
pop ax
pop bp
ret 8
endp Visual_Deck



proc WaitForColor
Wait_For_Color: ; wait for color to be picked	
		mov ah, 1
		int 16h
		jz Wait_For_Color
		mov ah, 1
		int 16h
		cmp al, 2
		jae low_right
		jmp Wait_For_Color ; input not valid number
		low_right:
		cmp al, 5 ; scan codes of 1 - 4, it works fine	
		ja Wait_For_Color
ret
endp WaitForColor		
;-----------------------------------------------------------------------------------------
; Function waits for left click on Mouse
; In: None
; Out: cx holds x cord of press (need to shr), dx holds y and bx holds status of press (1)
;-----------------------------------------------------------------------------------------
proc WaitForLeftClick
push ax
push bx
ContinueWaitForLeftClick:
	mov ax, 3
	int 33h
	
	cmp bx, 1
	je ExitWaitForLeftClick	
	jmp ContinueWaitForLeftClick
ExitWaitForLeftClick:
pop bx
pop ax
ret
endp WaitForLeftClick

;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; This is the main game function. Each turn it shows the current player deck and waits for a correct card input or a draw. 
; If the card is playable (calls CanPlayCard) it plays the card, placing it on top of the discard pile and considers special effects ( TAKI, +2..)
; In: None
; Out: none
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
proc Main_Game

	Main_Game_Loop:
		call Hide_Mouse
		call GraphicMode
		call Print_Draw_Pile
		mov si, offset DiscardPile
		add si, [Discard_Pile_Size]
		dec si
		mov ax, [si]
		xor ah, ah
		push 100
		push 160
		push ax
		call Show_Card ; display card on top of discard pile in middle of screen
		;call Initialize_Mouse
		call Current_Turn ; display player turn
		
		; si will hold the hand offset, bx the offset hand size
		cmp [Player1Size], 0
		je Victory_One
		cmp [Player2Size], 0
		je Victory_Two
		
		cmp [Player_Turn], 0
		je Turn_one
		jmp Turn_Two
		
		Turn_one:
		mov si, offset Player1 ; points to the array, index changes according to card chosen
		mov bx, offset Player1Size
		push 170
		push 20
		push [Player1Size]
		push offset Player1
		call Visual_Deck ; show current deck
		mov [Interval], dx ; [Interval] holds distance between cards (constant)
		call Mouse
		call Limit_Mouse ; graphics unrelated to player
		jmp Before_Valid_Press
		
		;in case main pile is pressed, case is solved
		;if one of the cards was pressed. calculating the index from hand by substracting begin x and dividnig by the size of card plus interval.
		
		Turn_Two:
		mov si, offset Player2
		mov bx, offset Player2Size
		push 170
		push 20
		push [Player2Size]
		push offset Player2
		call Visual_Deck ; show current deck
		mov [Interval], dx
		call Mouse
		call Limit_Mouse ; graphics unrelated to player

		Before_Valid_Press:
		push si 
		push bx ; save hand and offset size of hand
		
		Valid_Press:
		cmp [Last_Plus_Two], 1
		je Skip_Plus_Two
		cmp [Last_Value], -4 ; check for +2 played last turn
		je Check_For_Two
		Skip_Plus_Two:
		call WaitForLeftClick ; first wait for input
		Clicked:
		shr cx, 1 ; actual x
		; check for draw 
		cmp dx, 70
		jb Maybe_Card
		cmp dx, 120
		ja Maybe_Card
		; now cmp x
		cmp cx, 30
		jb Maybe_Card
		cmp cx, 60
		ja Maybe_Card
		; if all conditions not reached, press was card pile
		jmp Draw_One_Card	
		
		Maybe_Card:
		push [Interval] 
		push dx
		push cx
		call Is_On_Card ; check for press on some card
			
		cmp ax, 0FFFFh ; the check
		je Press_Is_Card	
		xor bx, bx
		xor cx, cx
		xor dx, dx ; card was not valid, jmping to Valid_Press
		jmp Valid_Press ; input not card
			
		Press_Is_Card: 
		; these calculaions are done to understand position of card pressed in hand based on his x cord and interval between cards	
		;--------------------------------------------------------
		mov bx, cx ; x cordinate	
		sub bx, 11 ; distance
		mov ax, 18 ; width of card
		add ax, [Interval] ; distance of each card plus interval
		mov cx, ax ; distance of each card + interval
		mov ax, bx ; the actual X	
		div cl ; index in al
		xor ah, ah
		;---------------------------------------------------------
		add si, ax ; si points to the index of the card that was pressed
		mov [Current_Index], al ; save index of card ( it is legal) 
		mov ax, [si] ; card that was pressed
		xor ah, ah
		mov [Current_Value], al ; value of card

		push si ; card offset 	
		call CanPlayCard
		
		cmp cx, 5 ; the check
		je Card_Is_Right
		jmp Valid_Press ; card cannot be played, waiting for legal input

		Card_Is_Right:
		pop bx ; offset hand size
		pop si ; offset hand
		
		mov al, [Current_Index]
		xor ah, ah
		add si, ax ; point again to card that needs to be played
		
		push offset Discard_pile_size
		push offset DiscardPile
		push bx ; bx points to player1size or player2 size
		push si ; push the offet of card to play
		sub si, ax ; point si to beggining of hand
		push si ; offset start of hand
		call PlayACard ; play the card: take it out from hand, decrease the hand size, put it on discard pile and increase it's deck
		
		call Re_Show_Screen ; update screen after card was played
		mov [Last_Plus_Two], 0
		push si
		push bx ; push again hand offset and hand size
		
		; regardless of value, card was played and updated in discard pile
		; now, check for any special effects
		cmp [Current_Value], 124
		ja Special_Card_Played
		jmp Normal_Card_Played
		
		Normal_Card_Played: ; card below 124
		mov al, [Current_Value] ; get card
		mov dh, 10
		div dh ; ah has color, al has val
		
		cmp al, 10 ; check stop
		je stop_effect
		
		cmp al, 11 ; check direction
		je direction_effect
		
		cmp al, 12
		je plus_effect ; special effects of normal cards are covereds
		jmp Normal_Without_Effects
		
		stop_effect:
		pop bx
		pop si
		mov [Last_Color], ah
		mov [Last_Value], al
		jmp Main_Game_Loop
		
		direction_effect:
		pop bx
		pop si
		mov [Last_Color], ah
		mov [Last_Value], al
		jmp Main_Game_Loop
		
		plus_effect:
		pop bx
		pop si
		mov [Last_Color], ah
		mov [Last_Value], al
		jmp Main_Game_Loop
		
		Normal_Without_Effects:
		pop bx
		pop si ; offst hand
		mov [Last_Color], ah
		mov [Last_Value], al
		jmp Wait_For_Enter_Press ; turn is passed	
		
		Special_Card_Played:
		mov bl, [Current_Value]
		mov al, bl
		cmp al, -2
		je Change_Color_Effect
		cmp al, -3 
		je Super_Taki_Effect
		; now it is not change color or super taki, either +2 or TAKI
		cbw 
		mov dl, 10
		idiv dl
		neg ah
		cmp al, -4 ; check for plus two
		je Plus_Two_Effect
		cmp al, -1
		je Taki_Effect
		
		Super_Taki_Effect:
		; color stays the same
		; value changes
		; in this condition, change color cannot be played at all
		pop bx
		pop si ; return hand offset and hand size
		mov [Last_Value], al ; -3
		call Re_Show_Screen
		Super_Taki_Data: ; waiting for enter or color here, it first checks if enter was pressed, then if left click was pressed
		mov ah, 1
		int 16h 
		jz Check_Click_Super_Taki
		mov ah, 0
		int 16h ; check if keyboard was pressed
		cmp ah, 1ch ; check if enter was pressed. also check if the last card played was special, if so jump to the relative effects
		je Super_Taki_Exited
		jmp Check_Click_Super_Taki
		Super_Taki_Exited:
		cmp [Active_Special_Card_After_Super_Taki], 1
		je Check_Special_Cards_Cases_After_Super_Taki
		jmp Wait_For_Enter_Press ; variable is not active, turn passed
		Check_Click_Super_Taki:
		mov ax, 3
		int 33h
		cmp bx, 1
		je Clicked_After_Super_Taki
		jmp Super_Taki_Data
		Clicked_After_Super_Taki:
		shr cx, 1
		push [Interval]
		push dx
		push cx
		call Is_On_Card
		cmp ax, 0FFFFh ; the check for ax
		jne Super_Taki_Data ; left click was not a card
		;---------------------------------------------------------------
		push bx ; save hand offset size
		mov bx, cx ; x cordinate	
		sub bx, 11 ; distance
		mov ax, 18 ; width of card
		add ax, [Interval] ; distance of each card plus interval
		mov cx, ax ; distance of each card + interval
		mov ax, bx ; the actual X	
		div cl
		mov [Current_Index], al
		xor ah, ah
		add si, ax ; si points to the index of the card that was pressed
		mov ax, [si] ; get card that was pressed
		xor ah, ah
		pop bx ; return hand size offset
		cmp al, -2
		je Super_Taki_Data ; card chosen was change color and is unplayable
		;----------------------------------------------------------------- all of these are calculation to understand the location of card in hand in case pressed after playing super TAKI
		cmp al, 124 ; this is the value of the first special card: red stop
		ja After_Super_Taki_Is_Special
		; card is not special special
		mov dh, 10
		div dh
		cmp ah, [Last_Color] ; check if card chosen is same color as the card before super TAKI
		jne Super_Taki_Data ; input illegal
		; play the card
		push offset Discard_pile_size
		push offset DiscardPile
		push bx ; bx points to player1size or player2 size
		add si, [word ptr Current_Index] ; point to the card that was pressed
		push si ; push the offset of card to play
		sub si, [word ptr Current_Index] ; point to hand again 
		push si ; offset start of hand
		call PlayACard ; play the card: take it out from hand, decrease the hand size, put it on discard pile and increase it's deck
		call Re_Show_Screen
		mov [Last_Color], ah
		mov [Last_Value], al
		
		cmp al, 10
		je Another_Effect_In_Super_Taki
		cmp al, 11
		je Another_Effect_In_Super_Taki
		cmp al, 12
		je Another_Effect_In_Super_Taki
		jmp Card_After_Taki_Not_Special

		Another_Effect_In_Super_Taki:
		mov [Active_Special_Card_After_Taki], 1
		jmp Super_Taki_Data
		Card_After_Super_Taki_Not_Special:
		mov [Active_Special_Card_After_Taki], 0
		jmp Super_Taki_Data ; card played, waiting for next data
		
		After_Super_Taki_Is_Special: ; analyse the attributes in case of special card
		mov [Active_Special_Card_After_Super_Taki], 1 ; activate variable
		mov dh, 10
		idiv dh
		neg ah
		cmp ah, [Last_Color]
		jne Super_Taki_Data ; card chosen not in same color
		; play the card
		push offset Discard_pile_size
		push offset DiscardPile
		push bx ; bx points to player1size or player2 size
		add si, [word ptr Current_Index] ; point to the card that was pressed
		push si ; push the offet of card to play
		sub si, [word ptr Current_Index] ; point to hand again 
		push si ; offset start of hand
		call PlayACard ; play the card: take it out from hand, decrease the hand size, put it on discard pile and increase it's deck
		call Re_Show_Screen
		mov [Last_Value], al
		jmp Super_Taki_Data ; card was played, waiting for next input
		
		
		Check_Special_Cards_Cases_After_Super_Taki: ; if last card played was special, apply special effects
		cmp [Last_Value], -1
		je Taki_Effect
		cmp [Last_Value], -3 
		je Super_Taki_Effect
		cmp [Last_Value], -4
		je Plus_Two_Effect
		; special cases of special cards covered, the rest of the cases are cards that grant another turn
		jmp Main_Game_Loop
		
		
		Change_Color_Effect:
		pop bx
		pop si
		call WaitForColor ; wait for color input, between 1 to four	
		Allocate:
		dec al ; actual number
		mov [Last_Color], al
		mov [Last_Value], 0FEh ; the change color value
		call Re_Show_Screen
		jmp Wait_For_Enter_Press ; turn is passed
		
		Plus_Two_Effect:
		pop bx
		pop si
		mov [Last_Color], ah
		mov [Last_Value], al ; first put value and color in variables
		add [Draw_Two], 2
		; the next steps are right after turns begin
		call Re_Show_Screen
		jmp Wait_For_Enter_Press ; turn ends with player playing +2
		
		Check_For_Two:
		; this area is only reached if a plus two was played last turn and it wasn't the first card
		; now loop through the array, if +2 found only it can be played, if not must draw according to counter. If drawn, [Draw_Two] is reset
		; si is offset hand
		; bx is offset size of hand
		mov cx, 0 ; index
		mov dx, 10
		pop bx
		pop si ; hand size and offset
		Search_For_Two_Loop:
		add si, cx
		mov ax, [si]
		sub si, cx ; point again to hand offset
		xor ah, ah ; card from hand
		cmp ax, 124 ; first check for special card
		ja Possibilty_For_Plus_Two
		jmp Next_Card_For_Search
		Possibilty_For_Plus_Two:
		idiv dl
		neg ah
		cmp al, -4 ; plus two found, it must be played. cx is index
		je Play_It
		jmp Next_Card_For_Search ; card was special but not +2
		
		Play_It:
		; we want to wait for press before playing it. For it we need to understand the card cords.
		; We have interval between cards and index, therefore card is somewhere between 11 + (19+interval) * index
		mov di, cx ; index of plus two in hand
		Wait_For_Press_Two:
		call WaitForLeftClick
		shr cx, 1
		cmp dx, 155
		jbe Upper_Bound_Of_Two
		jmp Wait_For_Press_Plus_Two
		Upper_Bound_Of_Two:
		cmp dx, 186
		ja Wait_For_Press_Plus_Two
		; now y is correct
		; put in ax the lower bound according to calculation
		mov ax, 18
		add ax, [Interval]
		mul di; this is the (19+interval) * index part
		add ax, 11 ; this is the upper bound
		cmp cx, ax
		jb Wait_For_Press_Two
		add ax, 18 ; second bound of card
		cmp cx, ax
		ja Wait_For_Press_Two ; if input was too high, loop again, else refer to effect
		jmp Plus_Two_Effect ; now card has been played
		
		Next_Card_For_Search:
		inc cx
		;inc si
		cmp cx, [bx] ; cmp to size
		jb Search_For_Two_Loop
		; if exited, there is no +2 in hand, and there must be draw
		
		sub si, cx ; point si again to begining of hand
		Wait_For_Press_Plus_Two: ; now wait for press on discard pile, then draw. This is only a draw case for the plus two
		call WaitForLeftClick
		shr cx, 1
		cmp dx, 70
		jb Wait_For_Press_Plus_Two
		cmp dx, 120
		ja Wait_For_Press_Plus_Two
		; now cmp x
		cmp cx, 30
		jb Wait_For_Press_Plus_Two
		cmp cx, 60
		ja Wait_For_Press_Plus_Two
		; if all conditions not reached, press was on picture.
		jmp Draw_That_Much
		
		Draw_That_Much:
		mov [Drawn_Last_Turn], 1
		push bx
		push si
		push [Draw_Two] ; amount to draw
		push offset Global_arr_size
		push offset GlobalArr
		call DrawXCards ; create first hand
		mov [Draw_Two], 0
		; instead of jumping to Re_Show_Deck, show changes here.
		call Re_Show_Screen
		jmp Wait_For_Enter_Press ; player drew cards and his turn ended	
		
		
		Taki_Effect:
		; color stays the same
		; value changes
		; in this condition, change color cannot be played at all
		pop bx
		pop si ; return hand offset and hand size
		mov [Last_Value], al ; -3
		mov [Last_Color], ah
		call Re_Show_Screen
		Taki_Data: ; waiting for enter or color here, it first checks if enter was pressed, then if left click was pressed
		mov ah, 1
		int 16h 
		jz Check_Click_Taki
		mov ah, 0
		int 16h
		cmp ah, 1ch ; check if enter was pressed. also check if the last card played was special, if so jump to the relative effects
		je Taki_Exited
		jmp Check_Click_Taki
		Taki_Exited:
		cmp [Active_Special_Card_After_Taki], 1
		je Check_Special_Cards_Cases_After_Taki
		jmp Wait_For_Enter_Press ; variable is not active, turn passed
		Check_Click_Taki:
		mov ax, 3
		int 33h
		cmp bx, 1
		je Clicked_After_Taki
		jmp Taki_Data
		Clicked_After_Taki:
		shr cx, 1
		push [Interval]
		push dx
		push cx
		call Is_On_Card
		cmp ax, 0FFFFh ; the check for ax
		jne Taki_Data ; left click was not a card
		;---------------------------------------------------------------
		push bx ; save hand offset size
		mov bx, cx ; x cordinate	
		sub bx, 11 ; distance
		mov ax, 18 ; width of card
		add ax, [Interval] ; distance of each card plus interval
		mov cx, ax ; distance of each card + interval
		mov ax, bx ; the actual X	
		div cl
		mov [Current_Index], al
		xor ah, ah
		add si, ax ; si points to the index of the card that was pressed
		mov ax, [si] ; get card that was pressed
		xor ah, ah
		pop bx ; return hand size offset
		cmp ax, -2
		je Taki_Data ; card chosen was change color and it is unplayable
		;----------------------------------------------------------------- all of these are calculation to understand the location of card in hand in case pressed after playing TAKI
		cmp al, 124 ; this is the value of the first special card: red stop
		ja After_Taki_Is_Special
		; card is not special special
		mov dh, 10
		div dh
		cmp ah, [Last_Color] ; check if card chosen is same color as the card before TAKI, if yes it is playable
		jne Taki_Data ; input illegal
		; play the card
		push offset Discard_pile_size
		push offset DiscardPile
		push bx ; bx points to player1size or player2 size
		add si, [word ptr Current_Index] ; point to the card that was pressed
		push si ; push the offset of card to play
		sub si, [word ptr Current_Index] ; point to hand again 
		push si ; offset start of hand
		call PlayACard ; play the card: take it out from hand, decrease the hand size, put it on discard pile and increase it's deck
		call Re_Show_Screen ; re show
		mov [Last_Color], ah
		mov [Last_Value], al
		
		cmp al, 10
		je Another_Effect_In_Taki
		cmp al, 11
		je Another_Effect_In_Taki
		cmp al, 12
		je Another_Effect_In_Taki
		jmp Card_After_Taki_Not_Special

		Another_Effect_In_Taki:
		mov [Active_Special_Card_After_Taki], 1
		jmp Taki_Data
		Card_After_Taki_Not_Special:
		mov [Active_Special_Card_After_Taki], 0
		jmp Taki_Data ; card played, waiting for next data
		
		After_Taki_Is_Special: ; analyse the attributes in case of special card
		mov [Active_Special_Card_After_Taki], 1 ; activate variable
		mov dh, 10
		idiv dh
		neg ah
		cmp ah, [Last_Color]
		jne Taki_Data ; card chosen not in same color
		; play the card
		push offset Discard_pile_size
		push offset DiscardPile
		push bx ; bx points to player1size or player2 size
		add si, [word ptr Current_Index] ; point to the card that was pressed
		push si ; push the offet of card to play
		sub si, [word ptr Current_Index] ; point to hand again 
		push si ; offset start of hand
		call PlayACard ; play the card: take it out from hand, decrease the hand size, put it on discard pile and increase it's deck
		call Re_Show_Screen
		mov [Last_Color], ah
		mov [Last_Value], al
		jmp Taki_Data ; card was played, waiting for next input
		
		
		Check_Special_Cards_Cases_After_Taki: ; if last card played was special, apply special effects
		cmp [Last_Value], -1
		je Taki_Effect
		cmp [Last_Value], -3 
		je Super_Taki_Effect
		cmp [Last_Value], -4
		je Plus_Two_Effect
		; special cases of special cards covered, the rest of the cases are cards that grant another turn
		jmp Main_Game_Loop
		
		
		Draw_One_Card:
		pop bx
		pop si ; return hand offset and hand size
		
		mov [Drawn_Last_Turn], 1
		mov [Last_Plus_Two], 1
		push bx ; offset hand size
		push si ; offset hand
		push 1 ; amount to draw
		push offset Global_arr_size
		push offset GlobalArr
		call DrawXCards ; create first hand
		
		call Re_Show_Screen ; re show deck with card drawn
		jmp Wait_For_Enter_Press
		
		Wait_For_Enter_Press:
		call WaitForEnterKey
		; add the delay with numbers function
		jmp Next_Turn ; enter pressed
		
		Next_Turn:
		mov [Turn], 1 ; this is a temporary variable to determine if to put some values in hand
		cmp [Player_Turn], 1
		je Set_Turn_To_Zero
		mov [Player_Turn], 1
		jmp Main_Game_Loop
		Set_Turn_To_Zero:
		mov [Player_Turn], 0
		jmp Main_Game_Loop
		
		
		Victory_One:
		mov cx,1
		jmp End_Game
		
		
		Victory_Two:
		mov cx, 2
		
End_Game:
ret 
endp Main_Game		

start:
	mov ax, @data
	mov ds, ax
	mov ax, 0a000h
	mov es, ax
	
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0

	mov cx, 20 ; shuffle, deal cards to players, one card to discard pile, play one card from first hand
	shuffling:
	push offset GlobalArr ; shuffle main deck, show main deck, give cards to both hands, show hand, play card from hand, show hand again, show message.
	push [Global_arr_size]
	call shuffle_deck
	loop shuffling
	
	mov bx, offset Active_Special_Card_After_Super_Taki
	mov si, offset Active_Special_Card_After_Taki
	mov di, offset Draw_Two
	mov si, offset Global_arr_size
	mov di, offset Discard_Pile_Size
	
	

	push offset Player1Size
	push offset Player1 
	push 8 ; amount to draw
	push offset Global_arr_size
	push offset GlobalArr
	call DrawXCards ; create first hand

	mov si, offset Player1
	
	push offset Player2Size
	push offset Player2 
	push 8 ; amount to draw
	push offset Global_arr_size
	push offset GlobalArr
	call DrawXCards ; create second hand

	mov di, offset Player2

	push offset Discard_Pile_Size
	push offset DiscardPile
	push 1
	push offset Global_arr_size
	push offset GlobalArr
	call DrawXCards ; draw one to discard pile
	
	mov si, offset DiscardPile
	add si, [Discard_Pile_Size]
	dec si
	mov ax, [si]
	xor ah, ah
	cmp al, 124
	ja First_Discard_Special
	mov dl, 10
	div dl
	mov [Last_Color], ah
	mov [Last_Value], al
	jmp After_Discard_Draw
	First_Discard_Special:
	cbw
	mov dl, 10
	idiv dl
	neg ah
	mov [Last_Color], ah
	mov [Last_Value], al
	cmp al, -4
	jne After_Discard_Draw
	mov [Last_Plus_Two], 1

	After_Discard_Draw:
	mov si, offset Player1
	call GraphicMode
	call Open_Picture
	call Initialize_Mouse ; initialize, show and limit mouse
	call Mouse
	call Limit_Mouse
	call Main_Game	
exit:
	mov ax, 4c00h
	int 21h
END start	
	