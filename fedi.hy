(import [os [path]])
(import requests)
(import [urllib.parse [urljoin]])
(import [pyaml [yaml]])
(import [getpass [getpass]])

(import common)

(defn register-client [base_url]
  (->
    base_url
    (urljoin "/api/v1/apps")
    (requests.post
      :data {"client_name" "hyfedi" "redirect_uris" "urn:ietf:wg:oauth:2.0:oob" "scopes" "read write follow"})
    (.json)))

(defn login [base_url client_id client_secret username password]
  (->
    base_url
    (urljoin "/oauth/token")
    (requests.post
      :data {"client_id" client_id "client_secret" client_secret "username" username "password" password
        "grant_type" "password" "scope" "read write follow"})
    (.json)))

(defn register-and-login [base_url]
  (setv client (register-client base_url))
  (->
      (login base_url
        (get client "client_id")
        (get client "client_secret")
        (input "Username: ")
        (getpass))
      (get "access_token")))

(defn get-visibility []
  (setv visibility (input "visibility: "))
  (if (in visibility ["public" "unlisted" "private" "direct"])
    visibility
    (get-visibility)))
    
(defn get-in-reply-to-id []
  (if (= (input "is this a reply (y/n)? ") "y")
    (input "id to reply to: ")
    None))

(defn post-loop [base_url token]
  (-> 
    base_url
    (urljoin "/api/v1/statuses")
    (requests.post
      :data {"status" (input "Status: ") "visibility" (get-visibility) "in_reply_to_id" (get-in-reply-to-id)}
      :headers {"authorization" token})
    (.json)
    (get "url")
    (print))
   (post-loop base_url token))
        
(setv config (common.read-config))
(if (not (in "base_url" config))
  (assoc config "base_url" (input "Base url: ")))

(common.write-config config)

(if (not (in "token" config))
  (assoc config "token" (register-and-login (get config "base_url"))))
(common.write-config config)

(post-loop (get config "base_url") (+ "Bearer " (get config "token")))
