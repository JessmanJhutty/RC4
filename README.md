# RC4 Encryption and Decryption
Given a decrypted message and a secret key we can decode this message using rc4 algorithim with fsms. Multiple FSMS were used with a start/finish protocol.
Fisrt fsm is initialize the memory in one memory block, the next fsm shuffles this memory which is then decrypted and then checked to see if the charatcers are ascii english characters or garabage. They key is then updated and the process starts again.
