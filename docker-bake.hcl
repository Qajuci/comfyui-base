variable "TAG" {
  default = "slim"
}

# === Version Pins (single source of truth) ===
variable "COMFYUI_VERSION" {
  default = "v0.18.2"
}
# MANAGER_SHA: 66108ccdbc8c -> 2e93040db50ea96e7655e90c1ddbadcfa9a67811 (CHANGED)
variable "MANAGER_SHA" {
  default = "2e93040db50ea96e7655e90c1ddbadcfa9a67811"
}
# KJNODES_SHA: 4e1458c2417d -> 7f43f2ce910a27971bdbbf3fb5a52081457f32e2 (CHANGED)
variable "KJNODES_SHA" {
  default = "7f43f2ce910a27971bdbbf3fb5a52081457f32e2"
}
# CIVICOMFY_SHA: 555e984bbcb0 -> 555e984bbcb02fc955075cb8eb699a6884c51239 (CHANGED)
variable "CIVICOMFY_SHA" {
  default = "555e984bbcb02fc955075cb8eb699a6884c51239"
}
# RUNPODDIRECT_SHA: 8be7b2206b75 -> 8be7b2206b75b896331cb2afaf1f670e4ebeec1a (CHANGED)
variable "RUNPODDIRECT_SHA" {
  default = "8be7b2206b75b896331cb2afaf1f670e4ebeec1a"
}
# GGUF_SHA: 6ea2651e7df66d7585f6ffee804b20e92fb38b8a (unchanged)
variable "GGUF_SHA" {
  default = "6ea2651e7df66d7585f6ffee804b20e92fb38b8a"
}
# IMPACTPACK_SHA: 429d0159ad429e64d2b3916e6e7be9c22d025c3c (unchanged)
variable "IMPACTPACK_SHA" {
  default = "429d0159ad429e64d2b3916e6e7be9c22d025c3c"
}
# Regular image (cu128)
variable "TORCH_VERSION" {
  default = "2.10.0+cu128"
}
variable "TORCHVISION_VERSION" {
  default = "0.25.0+cu128"
}
variable "TORCHAUDIO_VERSION" {
  default = "2.10.0+cu128"
}
# 5090 image (cu130) — can diverge from regular when needed
variable "TORCH_VERSION_5090" {
  default = "2.10.0+cu130"
}
variable "TORCHVISION_VERSION_5090" {
  default = "0.25.0+cu130"
}
variable "TORCHAUDIO_VERSION_5090" {
  default = "2.10.0+cu130"
}
variable "FILEBROWSER_VERSION" {
  default = "v2.59.0"
}
variable "FILEBROWSER_SHA256" {
  default = "8cd8c3baecb086028111b912f252a6e3169737fa764b5c510139e81f9da87799"
}

group "default" {
  targets = ["common", "dev"]
}

# Common settings for all targets (defaults to regular CUDA 12.8 / cu128)
target "common" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64"]
  args = {
    COMFYUI_VERSION     = COMFYUI_VERSION
    MANAGER_SHA         = MANAGER_SHA
    KJNODES_SHA         = KJNODES_SHA
    CIVICOMFY_SHA       = CIVICOMFY_SHA
    RUNPODDIRECT_SHA    = RUNPODDIRECT_SHA
    GGUF_SHA            = GGUF_SHA
    IMPACTPACK_SHA      = IMPACTPACK_SHA
    TORCH_VERSION       = TORCH_VERSION
    TORCHVISION_VERSION = TORCHVISION_VERSION
    TORCHAUDIO_VERSION  = TORCHAUDIO_VERSION
    FILEBROWSER_VERSION = FILEBROWSER_VERSION
    FILEBROWSER_SHA256  = FILEBROWSER_SHA256
    CUDA_VERSION_DASH   = "12-8"
    TORCH_INDEX_SUFFIX  = "cu128"
  }
}

# Regular ComfyUI image (CUDA 12.8 — default)
target "regular" {
  inherits = ["common"]
  tags = [
    "runpod/comfyui:${TAG}-cuda12.8",
    "runpod/comfyui:cuda12.8",
    "runpod/comfyui:latest",
  ]
}

# Dev image for local testing
target "dev" {
  inherits = ["common"]
  tags = ["runpod/comfyui:dev"]
  output = ["type=docker"]
}

# Dev push targets (for CI pushing dev tags, without overriding latest)
target "devpush" {
  inherits = ["common"]
  tags = ["runpod/comfyui:dev-cuda12.8"]
}

target "devpush-cuda13" {
  inherits = ["common"]
  tags = ["runpod/comfyui:dev-cuda13.0"]
  args = {
    TORCH_VERSION       = TORCH_VERSION_5090
    TORCHVISION_VERSION = TORCHVISION_VERSION_5090
    TORCHAUDIO_VERSION  = TORCHAUDIO_VERSION_5090
    CUDA_VERSION_DASH   = "13-0"
    TORCH_INDEX_SUFFIX  = "cu130"
  }
}

# CUDA 13.0 image (Blackwell / RTX 5090+)
target "cuda13" {
  inherits = ["common"]
  tags = [
    "runpod/comfyui:${TAG}-cuda13.0",
    "runpod/comfyui:cuda13.0",
  ]
  args = {
    TORCH_VERSION       = TORCH_VERSION_5090
    TORCHVISION_VERSION = TORCHVISION_VERSION_5090
    TORCHAUDIO_VERSION  = TORCHAUDIO_VERSION_5090
    CUDA_VERSION_DASH   = "13-0"
    TORCH_INDEX_SUFFIX  = "cu130"
  }
}
