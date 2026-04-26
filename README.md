Written by Benjamin Reichler
April 26, 2026



## Running

Open in Processing. 


##### Generating new Automaton
- If you want to generate a new random arrangement of pitches, set LOAD\_FROM\_SAVE to false and hit run. 
- You can customize the number of cells in your new arrangement by setting CELLS\_PER\_GENERATION and NUM\_GENERATIONS.
- You can customize the number of parent cells used to calculate new pitches using PARENTS\_PER\_CELL.

##### Loading from File
- If you want to load a saved arrangement of pitches from a JSON file, set LOAD\_FROM\_SAVE to true, FILENAME\_LOADFROM to the desired filename, and DOWNLOADS\_DIRECTORY to the directory to look for FILENAME\_LOADFROM in, starting in the same directory where the project file is downloaded, and hit run.
- To find FILENAME\_LOADFROM in a directory elsewhere, use "../" and path traversal.

##### Saving Files
- If you want to download your current arrangement of pitches, make sure you have clicked on the interactive pop-out window and press 's'. File sizes are usually around 15 KB.

##### Visual and Auditory Customization
- Changing CELL\_SIDE\_LENGTH will affect the size of each cell, therefore affecting the size of the interactive pop-out window.
- Changing MAXIMUM\_CELL\_VOLUME limits overall sound production and can reduce graininess and clicking in sound.
- Changing FURTHEST\_AUDIBLE\_CELL sets how far from the mouse cursor a cell may be heard.
- Increasing SOFTEN\_HIGH\_PITCHES will further dampen the volume produced by cells playing a higher pitch, which can help to improve balance and minimize discomfort during usage, especially for those sensitive to higher pitches.



## Background

During the Spring of 2026, I studied CSE 355: "Introduction to Theoretical Computer Science" at Arizona State University under the direction of the amazing professor Heni Ben Amor. Automata theory is the cornerstone which much of the class is built on, and sets the groundwork for the Chomsky Hierarchy. One such automaton, a Cellular automaton, births generations of cells with some properties derived from simple rules and the cells which preceded it, its "ancestors." 


Music and harmony have always been a large part of my life; I am minoring in Music Performance, with a concentration on the Viola, at ASU, and I have performed in orchestras and chamber groups while growing up. The theory of harmony and consonance has always been of interest to me, as it is the point where music and math, two subjects of importance to me. Through this project, I have brought both music and math to the world of computation and programming, and now we have a whole variety of some of my favorite subjects to play with in a single project!


My goal in this project has been to use simple mathematical constraints and rules related to music theory and harmony to take a selection of pitches (each measured in hertz) initially chosen at random (within a given range) and tune and tweak each of these pitches slowly each generation towards a more consonant harmony when multiple of these pitches close to each other are played as sign waves simultaneously.



## Music Theory

Generally two frequencies tend to sound more resonant together when the ratio between the pitches are simple, rational values. This is because when the peaks and troughs of two sine waves line up regularly and predictably, the brain can easily process what is happening and feel it is stable. For example, the ratio between a perfect unison is 1 : 1, between an octave is 2 : 1, between a perfect 5th is 3 : 2, between a perfect 4th is 4 : 3. Meanwhile, dissonant intervals use less simple ratios, like the minor 2nd which is 16 : 15, the major 7th which is 15 : 8, and the dreaded tritone which may be represented anywhere from 45 : 32 to 64 : 45! These less stable ratios often produce a clicking, beating, or pulsing sensation within our brains.


In truth, most modern music does not completely follow these simple ratios because doing so does not place half steps in our 12-tone scale equally far apart, meaning music may sound great in one key and awful in another. Instead of tuning with these simple ratios, usually called just tuning, we generally tune to equal temperament, where each semitone is exactly the twelfth-root of 2 times higher than the semitone before it. This preserves only the harmony between octaves, and approximates the rest of the intervals. Most people consider it "good enough," but many find the simple ratios approximated with irrational ones disconcerting. This project rewards just tuning in simple ratios.
