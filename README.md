# Five-to-one (521)
## Manifesto, Roadmap, and Milestones.
A free-software to implement the Warren Buffet &amp; Charles Munger (WBCM) '5/25 model' into a "To Do" app. 

We the people <i> "gonna make it, baby, in our prime". </i>
   
    WBCM's 5/25 prioritization method prescribes:
     - listing 25 to-do items
     - prioritizing them
     - pick the top 5 as things to focus on first.
     - dont touch the other 20 tasks until completion.
    
    
The 5/25 rule by WBCM allows you to focus your thoughts and achieve success in your goals instead of <i>"Trade in your hours for a handful dimes". </i>

   - Make 5 tasks serve 1 goal ( *Five to one, baby* )
   - Prioritize 1 from each 5 tasks ( *one in five* )
   - [YOL0](#yol-now) ( *no one here gets out alive, now* )
   - Important vs. Urgent ( *You get yours baby, I get mine* )
   - Change yourself with internal-dialogue ( *gonna make it baby, if we try* )

## Milestones on the Road Map
0. [MVP](#milestone-0)
   1. [Use Case](#initial-use-case)
      * [User Flow](#user-flow)
   2. [Wireframes](../Design-Plan/Wireframes)
   3. Rails API [!*Current IP*]
   4. UI - Web Browser 
   5. UI - Native
1. Features
   * Timeline Text annotation(GUI->M3!)
   * ..
2. UX
   * scrolling MRU
   * ..
3. Integrations
   * timeline mvp

With a name backed by the Doors song, the App is meant to assist people to take back control of thier lives. We no longer need to hear another human complain: <i> "Shadows of the evening crawl across the years" </i>

A key challenge to solve for: Dedicated use of the app as a to do list (and a not to do list)

# The App Design 


![alt text][home-screen]

[home-screen]:https://github.com/toknowjoyman/five-to-one/raw/master/Design-Plan/Wireframes/Getta-User_Dashboard.png "Circular 5 mode - First Draft"


![alt text][notToDo-list]

[notToDo-list]: https://github.com/toknowjoyman/five-to-one/raw/master/Design-Plan/Wireframes/Getta-Not_to_do_list.png "Task List - First Draft"

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

## Milestone 0
* create tasks
* prioritize tasks
* Execute a task
   * look through tasks
* update task

# App Development 

## todo-item
A todo-item object has a title, a parent todo-item

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
