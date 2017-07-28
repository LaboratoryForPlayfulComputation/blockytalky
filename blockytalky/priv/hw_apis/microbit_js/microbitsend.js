//author :@sahana sadagopan
//Javascript code on microbit to send
let receivedString = ""
// basic.forever(() => { let receivedString =
// "SendNum^32" handleReceivedData(receivedString) })
serial.onDataReceived(serial.delimiters(Delimiters.Hash), () => {
    basic.showString(serial.readString())
    receivedString = serial.readString()
    handleReceivedData(receivedString);
})
radio.setGroup(8)
// testing code here
let NthOccurenceOfCharacterInstring = function (inputstring: string, delimiter: string) {
    let delimeterfound = 0;
    let str = ['']
    for (let index = 0; index < inputstring.length; index++) {
        if (inputstring.charAt(index) == delimiter) {
            delimeterfound++;
        }
        else {
            str[delimeterfound] += inputstring.charAt(index)
        }
    }
    return str
}
let handleReceivedData = function (inputString: string) {
    let carrat = "^"
    let array = NthOccurenceOfCharacterInstring(inputString, carrat)
    if (array[0] == "SendNum") {
        basic.showString(array[1])
        let nu = parseInt(array[1])
        input.onButtonPressed(Button.A, () => {
            radio.sendNumber(nu)
        })
    }
    else if (array[0] == "Keyvalue") {
        basic.showString(array[1])
        basic.showString(array[2])
        let val = parseInt(array[2])
        radio.sendValue(array[1], val)
    }
    else if (array[0] == "setgroup") {
        basic.showString(array[1])
        let groupid: number = parseInt(array[1])
        radio.setGroup(groupid)
        radio.sendValue("setgroup", groupid)
    }
}