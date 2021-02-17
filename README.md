# TensorRT Onnx Conversion App

Flask app for converting ONNX runtimes to TensorRT engines and deployed on Google Kubernetes Engine. Example usage would be something like

```python
import requests
import pickle
from io import BytesIO

import torch
from tritonclient.grpc import model_config_pb2 as model_config


app_url = "<ip addr of GKE service>:5000/onnx"
export_path = "/path/to/save/model/to/model.plan"

# initialize the model
model = torch.nn.Sequential(
    torch.Linear(64, 1)
)

# do onnx export to bytes stream
stream = BytesIO()
torch.onnx.export(
    model,
    torch.ones((1, 64)),
    stream,
    input_names=["x"],
    output_names=["y"]
)

# create the model config
config = model_config.ModelConfig(
    name="my_nn",
    platform="tensorrt_plan",
    input=[
        model_config.ModelInput(
            name="x",
            data_type=model_config.TYPE_FP32,
            dims=[1, 64]
        )
    ],
    output=[
        model_config.ModelOutput(
            name="y",
            data_type=model_config.TYPE_FP32,
            dims=[1, 1]
        )
    ]
)

# create request data
data = {
    "network": stream.getvalue(),
    "config": config.SerializeToString()
}

# send request
response = requests.post(
    app_url,
    data=data,
    headers={"Content-Type": "application/octet-stream"}
)

# parse response content to get engine binary
engine = response.content

with open(export_path, "wb") as f:
    f.write(engine)
```
Consider using the [exportlib](https://github.com/alecgunny/exportlib) where this sort of application is wrapped up for you.
