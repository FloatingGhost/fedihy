(import [os [path]])
(import requests)
(import [urllib.parse [urljoin]])
(import [pyaml [yaml]])

(defn read-config []
  (if (.exists path ".cfg.yaml")
      (->
        ".cfg.yaml"
        (open "r")
        (yaml.load :Loader yaml.FullLoader))
      {}))

(defn write-config [config]
  (.dump yaml
    config
    (open ".cfg.yaml" "w")))
