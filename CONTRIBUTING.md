Contributing to SFH-project
===========================

We welcome your help and contributions.  This project is an [AgileVentures](http://AgileVentures.org) project. 
It is a collaborative, open project that uses Agile methods. This GitHub repo is one part of the project. 


#### Here are the main tools we use to work together and handle our work-flow:

- We use **[our Project pages](http://www.agileventures.org/projects/shf-project)** to document the main information about the project


- We use **[PivotalTracker](https://www.pivotaltracker.com/n/projects/1904891)** to discuss, define, and track our work (tasks, issues, bugs, features, ....).  We don't use GitHub for this.

- We use **[our channel on Slack](https://agileventures.slack.com/messages/shf-project/)** to have ongoing discussions and share information.  
 
- We use **GitHub** as the main repository for our code (version control, branches) and merge in work (PRs).

_Details on all of this are below. Read on for more on how it all goes._
 
**If you find a bug, but aren't going to join the project,** then [feel free to create an issue here on GitHub](https://github.com/AgileVentures/shf-project/issues) . We'd love to have your feedback.

---
### Here's How to Join the Project:

1) You'll need (free) accounts for these tools:

- [GitHub](http://github.com)
- [Pivotal Tracker](http://www.pivotaltracker.com)
- [Slack](http://slack.com)


2) Once you have accounts for those, create a profile on AgileVentures:
     Go to [AgileVentures.com](http://www.agileventures.org/) and sign up (look in the upper right-hand corner).
     You can sign up with *your GitHub account.*  That way, your work on GitHub will automatically be connected to the project and our tools.

3) You should automatically get an email from info@agileventures.com that invites you to our Slack team.
 
 If you don't get the invite for some reason, just send email to info@agileventures.com. (It would be helpful if you included your GitHub account name just to be complete.)
 
4) Get connected to our Pivotal Tracker project:
 
- Go to the Slack channel for this project: #shf-project and say hello!
- Then ask to be connected to our Pivotal Tracker project. Tell us the email address you use with your Pivotal Tracker account.
 

Now start asking questions and talking on Slack, reading about what needs to be done on PivotalTracker, reviewing past meetings via the videos that were recorded, do some Pair Programming, and be a part of the project!
  

### Workflow: Working on Code, coordinating with GitHub

Here is an overview of the general process for contributing (working on a new feature or fixing a bug): 
   
    
    -> checkout 'develop' branch  (fast foward so you're up to date)
    -> create a branch for your work in your repo 
    -> write test(s) to pass -> get your tests passing 
    -> create a WIP PR -> discuss, revise as needed 
    -> remove 'WIP' when your PR is ready to be merged 
    -> PR is merged by a project manager 
    -> Yay!
      
Getting Started on the AV site provides detailed instructions       
    
### Detailed Guidelines:
  - [Defining Tasks with PivotalTracker and GitHub](#Defining-Tasks-with-PivotalTracker-and-GitHub)
    - [Features](#Features)
    - [Bug fixes](#Bug-fixes)
  - [GitHub Workflow](#GitHub-Workflow)
  - [Code Style](#Code-Style)      
  
  
---


## Defining Tasks with PivotalTracker and GitHub

We use [Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1904891) to manage our work on features, chores and bugfixes.
  

Defining, discussing, voting on them...

### Features
Any feature should include Cucumber acceptance tests and RSpec tests where appropriate.

We try to avoid view and controller specs, and focus purely on unit tests at the model and service level where possible.  


### Bug fixes

Fixing a bug should **start with the creation of a test that replicates the bug,** so that any bugfix submission will include an appropriate test as well as the fix itself.

A bugfix may include an acceptance test depending on where the bug occurred.



_TODO_  _where should this user story go in the code?  as a cucumber acceptance test or as a documentation block?  in the github issue?_

Where possible please include a user story in the following form to indicate the higher level issue that is being addressed:

```gherkin
As an administrator
So that I can try new project metrics
I would like to be able to be able to add metrics with the minimum amount of effort

As an investigator
So that I can see how projects performed historically on new metrics
I would like to be able to apply new metrics to historical data on projects

As a metric designer
So that I can share my new metric 
I would like to be able to package my metric into a gem as simply as possible

As a project supervisor
So that I can quickly review project progress
I would like a view of metrics for a project that loads within 7 seconds, and ideally even faster 

As an administrator of another site that has projects 
So that I can quickly and reliably get stats on all our projects
I would like to be able to access the project metrics via API

```


### GitHub Workflow
  
#### develop = The branch for doing work

Our default working branch is currently `develop`.  We do work by creating branches off `develop` for new features and bugfixes.  

##### Fork the repo if you haven't already.  
Each developer will usually work with a [fork](https://help.github.com/articles/fork-a-repo/) of the [main repository on Agile Ventures](https://github.com/AgileVentures/shf-project).
 
##### ...or sync your fork before starting on a new task
Before starting work on a new feature or bugfix, please ensure you have [synced your fork to upstream/develop](https://help.github.com/articles/syncing-a-fork/):

```
git pull upstream develop
```

Note that you should be re-syncing daily (even hourly at very active times) on your feature/bugfix branch to ensure that you are always building on top of very latest _develop_ code.

 
#### Create a new branch for your work
 
When you create a branch to work on your feature or bug-fix, the name of the branch should *start with the GitHub issue #,* followed by an underscore, then a few words that describe the issue (i.e. from the title of the issue).  

The format for branch names is [YYMMDD]-[short description]

  
For example, if you are working on a feature on 2 Nov 2016 and the title of that issue is "Add the CONTRIBUTING.md file", you can create and check out your branch like this:

```
git checkout -b 161102-add_contributing_md
```

Once you have your tests passing (or if you're stuck and need help), create (submit) a pull request (PR).


#### Sync again before you create a PR

Before you make a pull request it is a great idea to sync again to the upstream develop branch to reduce the chance that there will be any merge conflicts arising from other PRs that have been merged to _develop_ since you started work:

```
git pull upstream develop
```


#### Create a PR early so others can review/help: WIP PR

Be sure to create your PR against the **develop** branch!

Whatever you are working on, please open a "Work in Progress" (WIP) [pull request](https://help.github.com/articles/creating-a-pull-request/) (just start your PR title with "[WIP]" )
so that others in the team can comment on your approach.  Even if you hate your horrible code :-) please throw it up there and we'll help guide your code to fit in with the rest of the project.

Once your WIP PR has been reviewed by a project manager and is ready to be merged, edit the PR title and remove "[WIP]"

Here is [more information on creating (submitting) pull requests](how_to_submit_a_pull_request_on_github.md).


##### One change per PR

Please ensure that each commit in your pull request makes a _single_ coherent change and that the overall pull request only includes commits related to the specific GitHub issue that the pull request is addressing.
This helps the project managers understand the PRs and merge them more quickly.


If your PR is addressing a GitHub issue, please include a sensible description of your code and a tag `fixes #<issue-id>` e.g. :

```
This PR adds a CONTRIBUTING.md file and a docs directory

fixes #799
```

which will mean that the issue is automatically linked to the pull request in the GitHub interface and when the pull request gets merged the issue will be closed.



#### Pull Request Review

The project manager(s) will review the pull request for coherence with the specified feature or bug fix, and give feedback on code quality, user experience, documentation and git style.  Please respond to comments from the project managers with explanation, or further commits to your pull request in order to get merged in as quickly as possible.

To maximize flexibility, you can add the project managers as collaborators to your projectscope fork in order to allow them to help you fix your pull request, but this is not required.


#### Here's a Diagram of Our GitHub Workflow

![Flowchart of the Github workflow](github-flow.png)

## Code Style


We recommend the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide)

 