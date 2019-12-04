---
title: Create the users
description: In this step you learn how to create the Users that will participate in the Conversation.
---

# Create a User

Each participant in a Conversation is represented by a [User](/conversation/concepts/user) object and must be authenticated by the Client SDK. In a production application, you would typically store this user information in a database.

Execute the following commands to create two users, `USER1_NAME` and `USER2_NAME` who will log in to the Nexmo Client and participate in the chat.

```bash
nexmo user:create name="USER1_NAME"
nexmo user:create name="USER2_NAME"
```

This will return user IDs similar to the following:

```sh
User created: USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab
```

Make a note of these as you'll need them later.
