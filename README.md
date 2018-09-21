## openshift-jupyter-scala

### Build

```bash
% cd /path/to/openshift-jupyter-scala
% docker build -t registry/openshift-jupyter-scala:latest .
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

This image defaults the jupyter password to just 'jupyter'. If you want to set another password you can configure the `JUPYTER_NOTEBOOK_PASSWORD` environment variable on your pod.

The image is based on the [radanalytics.io](https://radanalytics.io/) base notebook image [base-notebook](https://github.com/radanalyticsio/base-notebook)

The latest rev of this image is based on the [jupyter-scala](https://github.com/jupyter-scala/jupyter-scala) project, which is now being packaged as `almond` on the `develop` branch.
It is built on top of the [ammonite](https://github.com/lihaoyi/Ammonite) Scala REPL.

In order to take advantage of the spark release pre-installed on this image,
you need to get spark's jar files onto the ammonite classpath.
This can be done by putting the following code on the first cell of your notebook:
```scala
// put the spark install from the base notebook image onto Ammonite's classpath
java.nio.file.Files.list(java.nio.file.Paths.get("/opt/spark/jars")).toArray.map(_.toString).foreach { fname =>
  val path = java.nio.file.FileSystems.getDefault().getPath(fname)
  val x = ammonite.ops.Path(path)
  interp.load.cp(x)
}
// Load the ammonite-spark package to get AmmoniteSparkSession
import $ivy.`sh.almond::ammonite-spark:0.1.1`
```

An example of connecting to a spark cluster using the `AmmoniteSparkSession` wrapper:
```scala
import org.apache.spark.sql._
val spark = {
    AmmoniteSparkSession.builder()
      .master("local[*]")
      .getOrCreate()
  }
```

Other examples of how to use this kernel can be found
[here](https://github.com/jupyter-scala/jupyter-scala).
