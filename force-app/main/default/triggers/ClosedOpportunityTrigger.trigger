// AFTER trigger: Opportunity.Id already exists, so WhatId can reference it.
// Bulk-safe: one list-collect pass, one DML at the end. No SOQL or DML in loop.
trigger ClosedOpportunityTrigger on Opportunity(after insert, after update) {

    // Collect tasks in a list — insert once at the end.
    List<Task> tasks = new List<Task>();

    // Trigger.new holds every record in this transaction. Iterating it
    // does not consume a SOQL query — it's in-memory.
    for (Opportunity opp : Trigger.new) {

        // Guard: only fire for Closed Won opportunities.
        // Trigger.old is null on insert, so skip the "already was Closed Won" check
        // on insert — all inserted records are new by definition.
        if (opp.StageName == 'Closed Won') {
            tasks.add(new Task(
                Subject = 'Follow Up Test Task',
                WhatId = opp.Id
            ));
        }
    }

    // One DML statement for the entire list. Governor limit: 1 of 150.
    if (!tasks.isEmpty()) {
        insert as user tasks;
    }
}