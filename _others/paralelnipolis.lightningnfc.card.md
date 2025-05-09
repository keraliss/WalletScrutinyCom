---
title: Paralelní Polis Lightning NFC Card
appId: paralelnipolis.lightningnfc.card
authors:
- danny
icon: paralelnipolis.lightningnfc.card.png
date: 2023-04-28
website: https://www.paralelnipolis.cz/en/wallet/
social:
- https://www.facebook.com/vejdiven/
provider: Paralelní Polis
country: CZ
meta: ok
verdict: wip

---

## Updated Review 2023-04-27

### [How it Works](https://www.paralelnipolis.cz/en/wallet/)

> You can find 3 different QR codes on your card. Two codes on the front (white) side are used for payments – sending and receiving. Content of these is also on your NFC badge which you can use to interact with ATMs and payment terminals.
>
> Black button allows you to receive funds – tap it on ATM while receiving or scan to receive.
>
> Red button – send can be used to withdraw funds. Single payment with send code is by default limited to 100k sats
(~40€). For bigger payment, you have to use web wallet interface or withdraw money to your own wallet.
> 
> These two codes are LNURLs and can be used with many Bitcoin Lightning wallets and services. You can top up your badge or withdraw money with your own Phoenix, Breez, BlueWallet, Wallet of Satoshi, Muun and many others by simply scanning these QR codes.
>
> You may also receive another sticker with receive code which can be used by anybody to send you money. Stick it anywhere and get tips.
>
> Third code on the black side of the card is address of your wallet. Scan it and open in your browser to access web application which can be used as Bitcoin Lightning wallet. Application is hosted by Paralelní Polis which is provider of Lightning infrastructure and liquidity.

The setup does come with a disclaimer: 

> Send code on your badge represents LNURL-withdraw. Anybody who accesses this code can steal your funds. By default withdraws are limited to 100k sats per withdraw with maximum 100 withdraws and 10 seconds between them. You can modify it to achieve higher security. In web interface of your wallet go to Manage extensions and enable LNURLw. Open it under Extensions field and modify withdraw link you see.

We clarified with them [some concerns on twitter](https://twitter.com/dannybuntu/status/1651540698100015104).

## Background (Previous Review 2022-05-17)

Rather than a company, Paralelní Polis embraces cypherpunk culture and is a socio-political movement. The ideals of decentralization and cryptoanarchy are emphasized in this group thus, it aligns with some core tenets of Bitcoin. 

They hold an annual event called the HCPP (Hackers Congress Paralelní Polis). 

## Description 

A more thorough description could be found in Mário Havel's Github [repository.](https://github.com/taxmeifyoucan/HCPP2021-Badge)

> NFC badge contains 2 fields: LNURL-withdraw for paying and LNURL-pay for receiving sats. These are static codes which are created and uploaded only once. To receive funds, user approaches a badge/reads a QR code with LNURL-pay to receive funds from a Bitcoin ATM. Received funds can be immediately spend by reading LNURL-withdraw for example by point of sale terminal. 
>
> LNURL pairs are created using LNbits. Each pair represents a user in LNBits instance. With a web address and user ID, user can easily access web interface of the wallet and manage badge funds there.
>
> Yes, this solution is custodial and involves trusting the LNURL server provider. However, compared to the previous model, it offers the same level of trust. Users can easily withdraw all funds to their own non-custodial wallet, which takes minimum fees and is easy thanks to LNBits feature Drain funds. It also offers security benefits because LNURL-withdraw can be limited to a maximum withdrawal amount, number of uses, and time between them. Privacy benefit - avoiding address reuse and not putting all data onchain is obvious.    

You can see the device in action here:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Credit card? How about a “Lightning card” developed by <a href="https://twitter.com/_TaxMeIfYouCan_?ref_src=twsrc%5Etfw">@_TaxMeIfYouCan_</a> and powered by <a href="https://twitter.com/lnbits?ref_src=twsrc%5Etfw">@lnbits</a>?<br><br>It’s incredible to think about how open-source Bitcoin tech will change human interactivity and commerce around the world in the coming years 🌍<a href="https://t.co/Wmor26M03O">pic.twitter.com/Wmor26M03O</a></p>&mdash; Alex Gladstein 🌋 ⚡ (@gladstein) <a href="https://twitter.com/gladstein/status/1444398232692576259?ref_src=twsrc%5Etfw">October 2, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script><br /><br />

> You can find 3 different QR codes on your card. Two codes on the front (white) side are used for payments – sending and receiving. Content of these is also on your NFC badge which you can use to interact with ATMs and payment terminals.
>
> Black button allows you to receive funds – tap it on ATM while receiving or scan to receive.
>
> Red button – send can be used to withdraw funds. Single payment with send code is by default limited to 100k sats
(~40€). For bigger payment, you have to use web wallet interface or
withdraw money to your own wallet.
>
> Third code on the black side of the card is address of your wallet. Scan it and open in your browser to access web application which can be used as Bitcoin Lightning wallet. Application is hosted by Paralelní Polis which is provider of Lightning infrastructure and liquidity.

## Analysis 

The provider describes the service as **custodial** since the wallet is hosted on a server. If it wasn't custodial, it would still lack a screen to check what is being signed, which is clearly a concern of the provider as they limit payments to 0.001BTC by default. 

