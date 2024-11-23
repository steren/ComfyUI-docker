 # ComfyUI Docker

Dockerfile for [ComfyUI](https://github.com/comfyanonymous/ComfyUI) and instructions to deploy it to Cloud Run

## Build and run locally

```
docker build . -t comfyui
docker run -p8080:8188 comfyui
```

## Deploy to Cloud Run

```
export PROJECT_ID=your-project-id
```

### Create a Cloud Storage bucket to store persistent data

We will store models, inputs and custom nodes in a bucket that we will then mount in the Cloud Run service.

```
export BUCKET=comfyui-$PROJECT_ID
gcloud storage buckets create gs://$BUCKET --location=us-central1
```

Create 4 folders in the bucket

```
gcloud storage folders create gs://$BUCKET/models
gcloud storage folders create gs://$BUCKET/custom_nodes
gcloud storage folders create gs://$BUCKET/input
gcloud storage folders create gs://$BUCKET/output
```

### Downloading a model

#### Manually

See [here](https://www.comflowy.com/preparation-for-study/model)

Download models and upload them to Cloud Storage:

```
gcloud storage cp model.safetensors gs://$BUCKET/models/checkpoints/
```

#### Using ComfyUI-Manager

Alternatively, if you want to be able to manage models from the UI, upload the `ComfyUI-Manager` custom node to Cloud Storage.

```
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
gcloud storage cp -R ComfyUI-Manager gs://$BUCKET/custom_nodes/ComfyUI-Manager
```

### Deploy

Deploy to Cloud Run with 1 GPU, mount the 4 folders from Cloud Storage at each locations.

```
gcloud beta run deploy comfyui --region us-central1 --project $PROJECT_ID  --source . \
        --gpu 1 \
        --port 8188 \
        \
        --add-volume name=myvol1,type=cloud-storage,bucket=$BUCKET,mount-options="only-dir=models" \
        --add-volume-mount volume=myvol1,mount-path=/comfyui/ComfyUI/models \
        \
        --add-volume name=myvol2,type=cloud-storage,bucket=$BUCKET,mount-options="only-dir=custom_nodes" \
        --add-volume-mount volume=myvol2,mount-path=/comfyui/ComfyUI/custom_nodes \
        \
        --add-volume name=myvol3,type=cloud-storage,bucket=$BUCKET,mount-options="only-dir=input" \
        --add-volume-mount volume=myvol3,mount-path=/comfyui/ComfyUI/input \
        \
        --add-volume name=myvol4,type=cloud-storage,bucket=$BUCKET,mount-options="only-dir=output" \
        --add-volume-mount volume=myvol4,mount-path=/comfyui/ComfyUI/output
```

