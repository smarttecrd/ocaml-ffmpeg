open FFmpeg
open Avutil
module VideoConverter = Swscale.Make (Swscale.BigArray) (Swscale.Frame)

let fill_image width height pixel_format frame nb_img write =

  let v_ctx = VideoConverter.create [] width height pixel_format width height pixel_format in
  let planes = Video.copy_frame_to_bigarray_planes frame in

  for frame_index = 0 to nb_img do
    let data_y, linesize_y = planes.(0) in
    for y = 0 to height - 1 do
      let off = y * linesize_y in
      for x = 0 to width - 1 do
        data_y.{x + off} <- x + y + frame_index * 3;
      done;
    done;

    let data_cb, _ = planes.(1) in
    let data_cr, linesize = planes.(2) in

    for y = 0 to (height / 2) - 1 do
      let off = y * linesize in
      for x = 0 to width / 2 - 1 do
        data_cb.{x + off} <- 128 + y + frame_index * 2;
        data_cr.{x + off} <- 64 + x + frame_index * 5;
      done;
    done;

    VideoConverter.convert v_ctx planes
    |> write;
  done;
  "Bigarray_scale.fill_image"

