//recieving blockytalky
radio.onDataPacketReceived(({ receivedNumber: nu }) => {
    basic.showNumber(nu)
})
radio.setGroup(8)