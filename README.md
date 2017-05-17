## openshift-jupyter-scala

### Build

```bash
% cd /path/to/openshift-jupyter-scala
% docker build -t registry/openshift-jupyter-scala:latest
% docker push registry/openshift-jupyter-scala:latest
```

### Run in OpenShift

```bash
oc run jupyter-scala --image=registry/openshift-jupyter-scala:latest --expose --port=8888
```
Image may take a couple minutes for OpenShift to pull down.

Next, create a route for the `jupyter-scala` service.
You should be able to open this route in your browser and get the
Jupyter home-page, including a Scala kernel option.

Various examples of how to use this `jupyter-scala` kernel can be found
[here](https://github.com/alexarchambault/jupyter-scala).
