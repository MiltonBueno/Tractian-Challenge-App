# TRACTIAN recruitment challenge.

This document aims to record some analyses made and decisions taken throughout the development of the project.

To check the performance difference between different approaches in the app development, I used Flutter DevTools.

One of the points analyzed was whether to initialize the ExpansionTiles (widgets that made up the widget trees) expanded or not:

The tests were conducted in profile mode to ensure greater accuracy, and at least three tests were performed for each situation to ensure this accuracy.

Expanded ExpansionTiles Initially
At the application startup:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/34250e0b-92f0-4b8a-af3e-244bc693cc58)

When opening the tobias unit:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/19bd9dac-b3d9-4e5a-a0ad-6d4e40b65e39)

Scrolling to location 1, where there are several "sublocations" within other "sublocations", all expanded, overloading the device:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/cfc33270-d283-438d-972f-329bbef87880)

It is not possible to test closing and opening of the ExpansionTiles after Location 1. However, testing both in tobias and jaguar, the performance was quite similar, not creating Janks.

Initially Closed ExpansionTiles
At the application startup:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/0dcb1aae-e7c5-4012-8eb2-74caa5c39021)

Interestingly, the simple change of initializing expanded or not caused a jank at startup, however, it was barely noticeable due to its short duration. Flutter DevTools then informed that this was a “Shader Jank” and that it was possible to resolve or optimize this type of situation by pre-compiling the shaders. After this process, the jank was resolved:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/afa76ed9-3ea0-4086-a55e-c05c47791a1e)


When opening the tobias unit:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/862505f0-feae-4c18-a5e1-4a6ba2fcff04)


Similarly, again a jank without shader pre-compilation, after the pre-compilation this was the result:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/8b5c27e1-4a07-4eb7-85b6-5af68b95880d)


Scrolling to location 1:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/51b9cdb8-5a9c-47cc-8cca-d0cd87cfa170)


There was a jank, but it was barely noticeable to the user.
During the opening of ExpansionTiles again, some janks occur, but they generally end up being barely noticeable by the user:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/04062b53-f37a-4624-a821-edfd88dc30e0)


It was possible to observe a pattern; the janks occur at the moment of the ExpansionTile opening, but it ends up being barely noticeable and the screen remains quite fluid:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/c1091075-ed7a-455c-b832-b0cc2c6d20b4)

For the sake of compilation, when initializing the ExpansionTiles expanded, and performing the shader pre-compilation, it is noticeable that there are still many janks, but there is an impression of being slightly more fluid for the user:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/f0c7b7eb-6a4f-4e54-a128-be636ec472b6)


Therefore, the decision for the project was to initialize the ExpansionTiles closed and pre-compile the shaders.


## Now conducting some tests using multithreading through compute.


Without the use of compute:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/07992f7a-1a15-4df9-8ec6-db706f7fbd42)


Using compute for heavy or laborious routines:

![image](https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/800d782e-ce5a-42b1-a3f1-326aba9a3496)

Using compute example:

https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/65cf3a25-602a-47d9-acc3-0265cbd0bd14

Not using compute example:

https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/e9a0364e-194b-47a0-9c30-a1ef06f10084

It was possible to notice some subtle differences trying to perform the same routine in the app.
The conclusion is that, although it is largely imperceptible to the user the difference between using compute or not, compute still offers some minor advantages, perceived through Flutter DevTools, therefore being my choice for the project.

## Testing responsiveness on different screen sizes, including tablets:

<img src="https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/fe570332-e297-4924-89be-a4f22df06f5b" width="300" height="400">

<img src="https://github.com/MiltonBueno/Tractian-Challenge-App/assets/83652168/687b2d1b-5c95-4dfd-ad3a-598f08ed5380" width="200" height="400">




