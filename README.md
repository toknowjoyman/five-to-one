# Five-to-one(521)
A free-software work-in-progress app to implement the Warren Buffet &amp; Charles Munger 5/25 rule into a todo app, s.t. we the people are <i> "gonna make it, baby, in our prime". </i>

The 5/25 rule by WBCM allows you to focus your thoughts and acheive success in your goals instead of <i>"Trade in your hours for a handful dimes". </i>

1. [Use Case](#initial-use-case)
    * User Flow
2. Wireframes 
3. Rails API
4. UI - Web Browser 
5. UI - Native

With a name inspired by the Doors song, the App is meant to assist people to take back control of thier lives. We no longer need to hear another human complain: <i> "Shadows of the evening crawl across the years" </i>

A key challenge to solve for: Dedicated use of the app as a to do list (and a not to do list)

# The App Design 

## Initial Use Case
Robert, who has too much to do, finds that Five to one (or should we call it 1 in 5) might help him prioritize his goals. 
On opening the App, he is greeted with an 'empty todo list' and informed that this is to list the 25 things that really matter to him that he is not able to satisfactorily focus on. 

After upto 5 things are listed, when robert clicks 'Done' the app asks him to select the 5 things for his prioirty list. When he presses "continue".

The app shows Robert the list of the 20 remaining items on his list. It shows him that it has renamed the list to "Avoid at all costs" Grayed out all the entries and locked the list. 

The App proceeds to the 'wheel screen' that shows Robert the 5 priorities he needs to work on. And gives him control again. 

On clicking one of the goals, The app shows Robert details, options and sub tasks related to the goal. 
This is the birthplace of a new app (Fractal ToDo), so in the meantime we will stick to keeping this part minimal. 

Allow Robert to add and see subtasks to each goal. Force(?) Robert to Set whether the Goal is "Urgent or Important", i.e. is the goal something he needs to complete to satisfy his external needs (reported to someoneelse) or his inner needs (only reported to oneself). 


### User Flow
[What is a todo item](#todo-item)

#### Executing a todo item

Open app -> select Goal -> select task or drill-down –> select subtask -> ACTION-PAGE (can be another app/irl task), Optionally annotate, Click Done --or-- Click To Be Continued. -> Returns to Goal Page

#### Creating new todo item


#### Checking old todo item (and updating it) 

# App Development 

## todo-item
A todo-item object has a title, a parent todo-item, and a list of children.

A todo-item may take the place of a goal, a primary task, or a subtask or subtask of subtask)

# Lyrics of the song for reference and inspiration
<i> Five to one, baby
One in five
No one here gets out alive, now
You get yours, baby
I'll get mine
Gonna make it, baby
If we try

<i>The old get old
And the young get stronger
May take a week
And it may take longer
They got the guns
But we got the numbers
Gonna win, yeah
We're takin' over
Come on!

<i>Your ballroom days are over, baby
Night is drawing near
Shadows of the evening crawl across the years
Ya walk across the floor with a flower in your hand
Trying to tell me no one understands
Trade in your hours for a handful dimes
Gonna' make it, baby, in our prime
