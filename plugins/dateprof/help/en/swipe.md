---
toc: Community
summary: Swiping in The App.
---

# Swiping
These commands allow you to interact with the Dating App.

`swipe` - Display the current profile to swipe.
`swipe <type>` - Swipe on the current profile.
`swipe <name>=<type>` - Swipe on the named character.
`swipe/list <type>` - Display your swipes.
`swipe/matches` - Display your matches and missed connections.

The valid types are: `interested`, `curious`, `skip`, and `missed connection`.

If you and somebody both swipe interested, you will have a `solid` match.
If one of you swipes interested, and the other curious, you will have an `okay` match.
If you and both swipe curious, you will have a `maybe` match.

If you have swiped either `interested` or `curious` on somebody and do not have
a match, but think it would be an interesting connection. You can swipe `missed
connection` to indicate that. You will show up as a `missed connection` match
for that person.

By default, you will see your own alts in The App. You can swipe on them and
they can match. These commands allow you to hide your alts in The App.

`swipe/alts <hide, show>[/all]` - Set it for yourself, optionally for all of your alts at once.
`swipe/alts <name>=<hide, show>` - Set it for a character that is one of your alts, or for any character if you are an admin with the `manage_apps` permission.
