import { Image } from "canvaskit-wasm";
export type Options = {
  img: string | ArrayBuffer | Uint8Array | Image; // 图片源
  resolution: [number, number]; // 画布分辨率
  makeShaderCubicParams?: [any, any, any, any]; // 设置图片模式，skia.image.makeShaderCubic
};
type GenericArray<T, L extends number> = [T, ...T[]] & { length: L };
export type ExpansionType = {
  type: "expansion";
  point: GenericArray<number, 2>;
  range: number;
  strength: number;
};
export type TwistType = {
  type: "twist";
  point: GenericArray<number, 2>;
  range: number;
  strength: number;
};
export type PerspectiveType = {
  type: "perspective";
  after: GenericArray<number, 8>;
  before: GenericArray<number, 8>;
};
export type ZoomType = {
  type: "zoom";
  point: GenericArray<number, 2>;
  strength: number;
};
export type TriangleType = {
  type: "triangle";
  strength: number;
  render: 0.0 | 1.0;
};
export type TiltShiftType = {
  type: "tiltShift";
  blurRadius: number;
  gradientRadius: number;
  startPoint: GenericArray<number, 2>;
  endPoint: GenericArray<number, 2>;
  render: 0.0 | 1.0;
};
export type LensType = {
  type: "lens";
  brightness: number;
  radius: number;
  angle: number;
  render: 0.0 | 1.0 | 2.0 | 3.0 | 4.0;
};
export type InkType = {
  type: "ink";
  strength: number;
};
export type HexagonalPixelateType = {
  type: "hexagonalPixelate";
  strength: number;
};
export type EdgeDetectType = {
  type: "edgeDetect";
  strength: number;
};
export type DotNoiseType = {
  type: "dotNoise";
  strength: number;
  angle: number;
};
export type ColorDotNoiseType = {
  type: "colorDotNoise";
  strength: number;
  angle: number;
};
export type ApplyParams =
  | ExpansionType
  | TwistType
  | PerspectiveType
  | ZoomType
  | TriangleType
  | TiltShiftType
  | LensType
  | InkType
  | HexagonalPixelateType
  | EdgeDetectType
  | DotNoiseType
  | ColorDotNoiseType;
