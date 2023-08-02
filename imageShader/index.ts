import { CanvasKit, Image, Shader } from "canvaskit-wasm";
import { ApplyParams, Options } from "./types";

export class ImageShader {
  private img: Options["img"];
  private canvasKit: CanvasKit;
  private options: Options;
  private imgObject!: Image;
  private imgShader!: Shader;
  private fragShader!: Shader;

  constructor(canvasKit: CanvasKit, options: Options) {
    this.img = options.img;
    this.canvasKit = canvasKit;
    this.options = options;
  }

  async apply(params: ApplyParams) {
    this.deleteImgShader();
    this.deleteFragShader();
    const fragShader = await this._apply(params);
    if (fragShader) {
      this.fragShader = fragShader;
    }
    return fragShader;
  }

  private async _apply(params: ApplyParams) {
    const { canvasKit, options } = this;
    const imgShader = await this.getImgShader();
    this.imgShader = imgShader;
    const baseUniform = [
      ...options.resolution,
      this.imgObject.width(),
      this.imgObject.height(),
    ];
    if (params.type === "expansion") {
      const frag = (await import("./wrap/expansion.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [
          ...baseUniform,
          ...params.point,
          params.range,
          params.strength,
        ],
        children: [imgShader],
      });
    }
    if (params.type === "twist") {
      const frag = (await import("./wrap/twist.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [
          ...baseUniform,
          ...params.point,
          params.range,
          params.strength,
        ],
        children: [imgShader],
      });
    }
    if (params.type === "perspective") {
      const frag = (await import("./wrap/perspective.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, ...params.before, ...params.after],
        children: [imgShader],
      });
    }
    if (params.type === "zoom") {
      const frag = (await import("./blur/zoom.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, ...params.point, params.strength],
        children: [imgShader],
      });
    }
    if (params.type === "triangle") {
      const frag = (await import("./blur/triangle.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, params.strength, params.render],
        children: [imgShader],
      });
    }
    if (params.type === "tiltShift") {
      const frag = (await import("./blur/tiltShift.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [
          ...baseUniform,
          params.blurRadius,
          params.gradientRadius,
          ...params.startPoint,
          ...params.endPoint,
          params.render,
        ],
        children: [imgShader],
      });
    }
    if (params.type === "lens") {
      const frag = (await import("./blur/lens.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [
          ...baseUniform,
          params.brightness,
          params.radius,
          params.angle,
          params.render,
        ],
        children: [imgShader],
      });
    }
    if (params.type === "ink") {
      const frag = (await import("./special/ink.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, params.strength],
        children: [imgShader],
      });
    }
    if (params.type === "hexagonalPixelate") {
      const frag = (await import("./special/hexagonalPixelate.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, params.strength],
        children: [imgShader],
      });
    }
    if (params.type === "edgeDetect") {
      const frag = (await import("./special/edgeDetect.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, params.strength],
        children: [imgShader],
      });
    }
    if (params.type === "dotNoise") {
      const frag = (await import("./special/dotNoise.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, params.strength, params.angle],
        children: [imgShader],
      });
    }
    if (params.type === "colorDotNoise") {
      const frag = (await import("./special/colorDotNoise.fs")).default;
      return getFragShader(canvasKit, {
        frag,
        uniforms: [...baseUniform, params.strength, params.angle],
        children: [imgShader],
      });
    }
    return null;
  }
  // 获取图片shader
  async getImgShader() {
    const { canvasKit, options } = this;
    const image = await this.getImageObject();
    let imgShader;
    if (options?.makeShaderCubicParams) {
      imgShader = image.makeShaderCubic.apply(
        this,
        options.makeShaderCubicParams
      );
    } else {
      imgShader = image.makeShaderOptions(
        canvasKit.TileMode.Clamp,
        canvasKit.TileMode.Clamp,
        canvasKit.FilterMode.Linear,
        canvasKit.MipmapMode.Linear
      );
    }
    return imgShader;
  }
  // 获取图片对象
  async getImageObject() {
    if (this.imgObject) return this.imgObject;

    if (typeof this.img === "string") {
      const imgData = await loadImage(this.img);
      this.imgObject = this.canvasKit.MakeImageFromEncoded(imgData)!;
      return this.imgObject;
    }
    if ((this.img as Image)?.getImageInfo) {
      this.imgObject = this.img as Image;
      return this.imgObject;
    }
    this.imgObject = this.canvasKit.MakeImageFromEncoded(this.img as any)!;
    return this.imgObject;
  }
  // 重新设置图片
  setImage(img: Options["img"]) {
    this.img = img;
    this.imgObject = undefined as any;
  }

  // 清除片元缓存
  deleteFragShader() {
    if (this.fragShader) {
      this.fragShader.delete();
    }
  }

  // 清除图片缓存
  deleteImgShader() {
    if (this.imgShader) {
      this.imgShader.delete();
    }
  }
}

// 网络加载图像
async function loadImage(src: string) {
  const response = await fetch(src);
  const arrayBuffer = await response.arrayBuffer();
  return arrayBuffer;
}

export function getFragShader(
  canvasKit: CanvasKit,
  options: {
    frag: string;
    uniforms: any[];
    children?: any[];
  }
) {
  const effect = canvasKit.RuntimeEffect.Make(options.frag)!;
  const shader = effect.makeShaderWithChildren(
    options.uniforms,
    options.children
  );
  return shader;
}
