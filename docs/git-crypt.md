# Add a new user for git-crypt
* start a new git branch `git checkout -b add-<name>-as-gpg-user`
* obtain the user key ID from a keystore (for example pgp.key-server.io)

        gpg --keyserver pgp.key-server.io --recv-key <key ID>
* add trust (optional/ to avoid having to use the `--trusted` flag):

        gpg --edit-key <email>
    - at the gpg prompt
        - first type: `trust`
        - then select a value

    - confirm
    - type `quit` to exit the gpg prompt
* add user to git-crypt:

        git-crypt add-gpg-user <email> --trusted

    This will create a commit with the appropriate changes

* Push your branch to github
* merge
