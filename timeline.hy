(import [os [path]])
(import requests)
(import [urllib.parse [urljoin]])
(import [pyaml [yaml]])
(import [time [sleep]])
(import common)

(defn print-statuses [statuses]
  (do
    (setv x (first statuses))
    (if (not (is x None))
      (do
        (print
          (.format 
            "{} ({}): {}"
            (get x "account" "acct")
            (get x "id")
            (get x "content")))
      (print-statuses (rest statuses))))))

(defn poll [config]
  (setv statuses
    (->
        (get config "base_url")
        (urljoin "/api/v1/timelines/home")
        (requests.get
            :headers {"authorization" (+ "Bearer " (get config "token"))}
            :params {"since_id" (get config "last_seen")})
        (.json)))
  (if (!= (len statuses) 0)
      (do 
          (setv last_seen (get (first statuses) "id"))
          (assoc config "last_seen" last_seen)
          (common.write-config config)
          (print-statuses statuses)))

  (sleep 5)
  (poll config))

(setv config (common.read-config))

(if (not (in "last_seen" config))
 (assoc config "last_seen" 0))

(common.write-config config)
(poll config)
