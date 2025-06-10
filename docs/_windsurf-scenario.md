# PDD with Windsurf AI

## initial prompts

```
    Read the file `docs/requirements.md`, extract key goals and constraints, and create a detailed implementation plan for the project. The plan should describe the rationale for each proposed change and be saved to `docs/plan.md`. Use clear section headers to organize the plan by theme or area of the system.
```


## create tasks from plan

```
    Create a detailed list of actionable improvement tasks and save it as an enumerated checklist to `docs/tasks.md`. 
    Each item should start with a placeholder [ ] to be checked off when completed. 
    Ensure the tasks are logically ordered and cover both architectural and code-level improvements.
```

## implement tasks/phases

```
    Proceed with to implement the application according to the tasks listed in docs/tasks.md. 
    Start with Phase 1. 
    Mark tasks as done [x] upon completion only if the task is fully implemented and the code compiles without errors.
    Please DO NOT start a new phase until i explicitly ask you
```

## follow up prompt for discovery service

```
    Сurrently we use hadcoded api for light bulb. Shelly bulb supports discovery via mdns. Implement logic using jmdns library (ask context7 for documentation). make sure don't bind to localhost interface (it wont' be able to dicover in local network). also cleanup ui - keep it on point and remove distracting elements. Add discovery status and bulb ip to ui.   
``