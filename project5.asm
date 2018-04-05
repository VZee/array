TITLE Arrays and Averages     (project5.asm)

; Author: Louisa Katlubeck
; OSU email: katlubel@oregonstate.edu
; CS 271-400 Project 5                 Due Date: 3/04/2018 (2 grace days used)
; Description: This program prompts the user to enter a number between 10 and 200, and then generates an array
; with that many entries. Entries are between 100 and 999. The program outputs the array, sorts the array in descending order,
; calculates and displays the median, and then outputs the sorted array.

INCLUDE Irvine32.inc

.const
; min, max, low, high, and line size values
	MIN			=		10
	MAX			=		200
	LO			=		100
	HI			=		999
	MAX_SIZE	=		200
	LINE_SIZE	=		10

.data
; greeting and goodbye
	greeting	BYTE	"Welcome to Project5.asm, Arrays and Averages. My name is Louisa. ", 0
	description	BYTE	"You will enter a number between 10 and 200, and that number of random integers will be displayed, and then sorted in descending order. The median of the list will also be calculated. ", 0
	goodbye		BYTE	"Thank you, goodbye. ", 0

; get user input
	getNum		BYTE	"Enter the number of random integers to display [10...200]: ", 0
	error		BYTE	"Number out of range. ", 0

	userNum		DWORD	?

; array
	numArr		DWORD	MAX_SIZE	DUP(?)

; median value 
	median		DWORD	?

; spaces 
	fiveSpaces	BYTE	"     ", 0

; unsorted, sorted, and median titles
	sorted		BYTE	"The sorted list is:", 0
	unsorted	BYTE	"The unsorted random numbers are:", 0
	medianTitle	BYTE	"The median is ", 0		

.code
main PROC
	call	Randomize
	call	introduction

	push	OFFSET userNum	
	call	getData

	push	OFFSET numArr
	push	userNum
	call	fillArray

	push	OFFSET numArr
	push	userNum
	push	LINE_SIZE
	push	OFFSET unsorted
	call	displayList

	push	OFFSET numArr
	push	userNum
	call	sortList

	push	OFFSET numArr
	push	userNum
	push	OFFSET medianTitle
	call	displayMedian

	push	OFFSET numArr
	push	userNum
	push	LINE_Size
	push	OFFSET sorted
	call	displayList


	call	farewell

	exit	; exit to the operating system
main ENDP

; program procedures
;
; description: introduction introduces the developer and the program
; receives: nothing
; returns: nothing
; registers changed: EDX
introduction PROC
	push	EBP
	mov		EBP, ESP

; introduce the developer and describe the program
	mov		EDX, OFFSET greeting
	call	WriteString
	call	Crlf
	mov		EDX, OFFSET description
	call	WriteString
	call	CrLf
	call	CrLf
	pop		EBP
	ret
introduction ENDP


; description: getData reads in the user data and validates the data
; receives: reference for userNum
; returns: user entered value of userNum
; registers changed: EDX, EAX, EBX
; get the user number
getData PROC
	push	EBP
	mov		EBP, ESP

getInput:
; get the user input
	mov		EBX, [EBP + 8]		
	mov		EDX, OFFSET getnum
	call	WriteString
	call	ReadInt

; check to make sure the number is greater than or equal to 10
	cmp		EAX, MIN
	jge		checkUpperBound
	jmp		getInput

; check to make sure the number is less than or equal to 200
checkUpperBound:
	cmp		EAX, MAX
	jle		doReturn
	jmp		getInput

doReturn:
	mov		[EBX], EAX
	pop		EBP
	ret		4
getData ENDP


; description: fillArray randomly generates an array of userNum entries, where each entry
; is between LO and HI
; preconditions: userNum contains the number of numbers to fill numArr with
; receives: numArr (empty), userNum
; returns: numArr (filled)
; registers changed: ECX, EDI
; code copied from lecture 19: introduction to arrays, slide 12, OSU CS Assembly Programming course
; and lecture 20 slide 6 from the same course
fillArray PROC
	push	EBP
	mov		EBP, ESP

; loop counter in ECX
	mov		ECX, [EBP + 8]

; start of numArr
	mov		EDI, [EBP + 12]

; loop to get userNum random numbers stored in numArr
getNextNum:
; generate a random number in the range [100..999]
	mov		EAX, HI
	sub		EAX, LO
	add		EAX, 1
	call	RandomRange
	add		EAX, LO

; store that number in numArr
	mov		[EDI], EAX
	mov		EAX, [EDI]
	add		EDI, 4

; loop until we have userNum values in numArr
	loop	getNextNum

; return starting address of numArr
	pop		EBP
	ret		8
fillArray ENDP


; description: sortList sorts the randomly generated array in decreasing order
; receives: offset to unsorted numArr and the size of numArr
; returns: starting address of numArr
; registers changed: ECX, EAX, ESI, EBX, EDX
; procedure is a modification of the bubble sort on p 375 of the Irvine textbook
sortList PROC
	push	EBP
	mov		EBP, ESP
; set up the loop counter
	mov		ECX, [EBP + 8]
	dec		ECX

; save ECX and get the first array number in ESI
outerLoop:
	push	ECX
	mov		ESI, [EBP + 12]

; compare adjacent values
innerLoop:
	mov		EAX, [ESI]
	mov		EBX, [ESI + 4]
	cmp		EAX, EBX

	jge		advanceESI
; exchange the elements if needed to sort array in decreasing order
	mov		EAX, [ESI + 4]
	mov		EBX, [ESI]
	mov		[ESI], EAX
	mov		[ESI + 4], EBX

; advance the pointers
advanceESI:
	add		ESI, 4
	loop	innerLoop

	pop		ECX
	loop	outerLoop

; return starting address of sorted numArr
	pop		EBP
	ret		8
sortList ENDP


; description: displayMedian calculates and displays the median of the randomly generated list 
; receives: offset for numArr, userNum
; returns: nothing
; registers changed: ECX, EBX, EAX, ESI
displayMedian PROC
	push	EBP
	mov		EBP, ESP

; ESI will be the start of the numArr array
	mov		ESI, [EBP + 16]

; EAX will be the count of how many items are in the array
	mov		EAX, [EBP + 12]

; find if median is the middle value or the average of two numbers
; divide the userNum by 2
	mov		ECX, 2
	div		ECX

; store the quotient in EBX
	mov		EBX, EAX

; see if the remainder is 0
	mov		EAX, EDX
	mov		ECX, 0
	cmp		EAX,  ECX
	je		averageMedian

; the median is the middle number
; EAX is now the numArr[i] i value we want to print (where i starts at 1)
	mov		EAX, EBX
; each item in numArr has a length of 4
	mov		EBX, 4
	mul		EBX

; get the appropriate location 
; ESI is now at the start of the array
	mov		ESI, [EBP + 16]
	add		ESI, EAX
; EAX is now the median value
	mov		EAX, [ESI]
	jmp		print

averageMedian:
; the median will be the average of two values
; ESI is now at the start of the array
	mov		ESI, [EBP + 16]
	mov		EAX, 4
	mul		EBX
	add		ESI, EAX
; EAX is now the second value to average
	mov		EAX, [ESI]
	sub		ESI, 4
; EBX is now the sum of the values
	add		EAX, [ESI]
	mov		EBX, 2
; EAX is now the median value
	div		EBX
	
print:
; print the median
	call	CrLf
	mov		EDX, [EBP + 8]
	call	WriteString
	call	WriteDec
	call	CrLf
	call	CrLf

	pop		EBP
	ret		8
displayMedian ENDP


; description: displayList outputs the randomly generated list to the screen, 10 items per line
; receives: numArr(filled), userNum
; returns: nothing
; registers changed: ECX, EBX, EAX, EDX, ESI
; code inspired by lecture 20 displaying arrays from OSU CS 271
displayList PROC
	push	EBP
	mov		EBP, ESP

; loop counter in ECX and number counter in EBX
	mov		ECX, [EBP + 16]
	mov		EBX, 0

; get and print the title
	xor		EDX, EDX
	mov		EDX, [EBP + 8]
	call	WriteString
	call	CrLf

; start of numArr
	mov		ESI, [EBP + 20]

; loop to get userNum random numbers stored in numArr
printNext:

; access the next number in numArr
	mov		EAX, [ESI]
	call	WriteDec
	xor		EDX, EDX
	mov		EDX, OFFSET fiveSpaces
	call	WriteString

; increment the count of how many numbers we've printed
	add		EBX, 1

; check to see if we need to print a new line
	xor		EDX, EDX
	mov		EAX, [EBP + 12]
	cmp		EAX, EBX
	jne		continueLoop
	call	CrLf
	mov		EBX, 0
; loop until we have printed all values in numArr
continueLoop:
	add		ESI, 4
	loop	printNext

	pop		EBP
	ret		8
displayList ENDP


; description: farewell says goodbye to the user 
; receives: nothing
; returns: nothing
; registers changed: EDX
farewell PROC
	call	CrLf
	mov		EDX, OFFSET goodbye
	call	WriteString
	call	CrLf
	call	CrLf
	ret
farewell ENDP

END main

