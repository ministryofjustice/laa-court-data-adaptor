# Add a new user for git-crypt

# Create a new Key ID and upload it to the gpg keyserver


1. Install GPG

2. Create a new GPG key pair (a public key and a private key).

`$ gpg --full-generate-key`

It asks:

    - "What kind of key do you want?" (You select RSA and RSA)
    - "What key size?" (You type 4096)
    - "When should it expire?" (You type 0 for no expiration)
    - "Your name?" (You type your name.)
    - "Your email?" (You type your email address.)

After a few seconds, your keys are ready to use!

3. Get the Last 8 Characters

Run this command:

`$ gpg --list-keys`

Look under the **pub** section for your key.

The long string below it (e.g., ABCDEF1234567890ABCDEF1234567890ABCDEF12) is your key fingerprint.

Take the last 8 characters from the fingerprint.
That's your KEY ID.

4. Send Your Key to a Keyserver

Now that you have your Key ID, you can send your public key to a keyserver:

`$ gpg --keyserver hkps://keyserver.ubuntu.com  --send-keys 12345678`

5. Ask the team lead to add you as collaborator

Contact the team lead, and give them the keyserver and key id.

They'll create a PR to add you in the list of people that can read the encrypted Env files.

## To add a new member to the team

This task is for the person responsible of the repo (usually the team lead)

* start a new git branch `git checkout -b add-<name>-as-gpg-user`
* obtain the user key ID from a keystore

    gpg --keyserver pgp.key-server.io --recv-key <key ID>

This command retrieves a public key from the keyserver and adds it to your local GPG keyring.

    The option `--keyserver` specifies the keyserver to query. In this case `pgp.key-server.io`.
    
    Other popular keyservers are:
    - keyserver.ubuntu.com
    - keys.openpgp.org 

* add trust (optional/ to avoid having to use the `--trusted` flag):

        gpg --edit-key <email>
    - at the gpg prompt
        - first type: `trust`
        - then select a value

    - confirm
    - type `quit` to exit the gpg prompt
* add user to git-crypt:

        git-crypt add-gpg-user --trusted <email>

    This will create a commit with the appropriate changes

* Push your branch to github
* merge
