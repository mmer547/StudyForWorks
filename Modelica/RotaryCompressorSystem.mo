package RotaryCompressorSystem
connector FluidPort
  Real p "圧力 [Pa]";
  flow Real q "体積流量 [m3/s]";annotation(
      Icon(graphics = {Rectangle(fillColor = {0, 0, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}})}));
end FluidPort;
model CentrifugalPump
  parameter Real rho = 850 "潤滑油の密度 [kg/m3]";
  parameter Real omega = 300.0 "軸回転速度 [rad/s]";
  parameter Real r_o = 0.01 "吐出口半径 [m]";
  parameter Real r_c = 0.005 "中心半径 [m]";

  Real dp;
  FluidPort a annotation(
      Placement(transformation(origin = {0, 94}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, 94}, extent = {{-10, -10}, {10, 10}})));
  FluidPort b annotation(
      Placement(transformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}})));

equation
  dp = rho * omega^2 * (r_o^2 - 0.5 * r_c^2) / 2;
  a.q + b.q = 0;
  a.p - b.p = dp;
end CentrifugalPump;
model Orifice
  parameter Real Cd = 0.7 "流量係数";
  parameter Real A = 5e-5 "断面積 [m2]";
  parameter Real rho = 850 "密度 [kg/m3]";
  Real dp;
  FluidPort a annotation(
      Placement(transformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}})));
  FluidPort b annotation(
      Placement(transformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}})));

equation
  a.q + b.q = 0;
  dp = a.p - b.p;
  a.q = Cd * A * sqrt(2 * abs(dp) / rho) * sign(dp);
end Orifice;

model Pipe
  parameter Real R = 1e5 "流体抵抗 [Pa/(m3/s)]";
  FluidPort a annotation(
      Placement(transformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}})));
  FluidPort b annotation(
      Placement(transformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}})));
equation
  a.q + b.q = 0;
  a.p - b.p = R * a.q;
end Pipe;

model RotaryCompressor
  parameter Real R_bearing = 5e4 "軸受部の抵抗";
  FluidPort a annotation(
      Placement(transformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}})));
  FluidPort b annotation(
      Placement(transformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}})));
equation
  a.q + b.q = 0;
  a.p - b.p = R_bearing * a.q;
end RotaryCompressor;

model Tank
  FluidPort port annotation(
      Placement(transformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}})));
equation
  port.p = 0;
end Tank;

model BearingOrifice
  parameter Real A = 5e-5 "オリフィス断面積 [m2]";
  parameter Real rho = 850 "油密度 [kg/m3]";
  parameter Real nu = 0.00003 "動粘度 [m2/s]";
  parameter Real r = 0.001 "オリフィス半径 [m]";
  parameter Real Cmod = 0.85 "修正係数";
  FluidPort a annotation(
      Placement(transformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {2, 96}, extent = {{-10, -10}, {10, 10}})));
  FluidPort b annotation(
      Placement(transformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {0, -98}, extent = {{-10, -10}, {10, 10}})));

  Real dp;
  Real Re;
  Real Cd;
equation
  a.q + b.q = 0;
  dp = a.p - b.p;
  Re = if abs(dp) > 0 then 2 * sqrt(2 * abs(dp) / rho) * r / nu else 0;
  Cd = smooth(1, if Re < 200 then 0.3 else if Re < 1000 then 0.3 + 0.0005*(Re-200) else 0.7);
  a.q = Cd * Cmod * A * sqrt(2 * abs(dp) / rho) * sign(dp);
end BearingOrifice;

model RotaryCompressorOilCircuit_WithBearingOrifice
  CentrifugalPump pump(rho=850, omega=300, r_o=0.01, r_c=0.005);
  Pipe pipe1(R=1e5), pipe2(R=2e5);
  BearingOrifice bearingOrifice(A=5e-5, rho=850, nu=3e-5, r=0.001, Cmod=0.85);
  RotaryCompressor compressor(R_bearing=5e4);
  Tank tank;

equation
  connect(tank.port, pump.a);
  connect(pump.b, pipe1.a);
  connect(pipe1.b, bearingOrifice.a);
  connect(bearingOrifice.b, compressor.a);
  connect(compressor.b, pipe2.a);
  connect(pipe2.b, tank.port);
end RotaryCompressorOilCircuit_WithBearingOrifice;

  model test
  Tank tank annotation(
      Placement(transformation(origin = {0, -84}, extent = {{-10, -10}, {10, 10}})));
  CentrifugalPump centrifugalPump(rho=850, omega=300, r_o=0.01, r_c=0.005) annotation(
      Placement(transformation(origin = {0, -48}, extent = {{-10, -10}, {10, 10}})));
  Pipe pipe(R=1e5) annotation(
      Placement(transformation(origin = {0, -16}, extent = {{-10, -10}, {10, 10}})));
  BearingOrifice bearingOrifice(A=5e-5, rho=850, nu=3e-5, r=0.001, Cmod=0.85) annotation(
      Placement(transformation(origin = {0, 20}, extent = {{-10, -10}, {10, 10}})));
  RotaryCompressor rotaryCompressor(R_bearing=5e4) annotation(
      Placement(transformation(origin = {0, 56}, extent = {{-10, -10}, {10, 10}})));
  Pipe pipe1(R=2e5) annotation(
      Placement(transformation(origin = {58, -34}, extent = {{-10, -10}, {10, 10}})));
  equation
    connect(centrifugalPump.b, tank.port) annotation(
      Line(points = {{0, -58}, {0, -74}}));
    connect(pipe.b, centrifugalPump.a) annotation(
      Line(points = {{0, -26}, {0, -38}}));
    connect(bearingOrifice.b, pipe.a) annotation(
      Line(points = {{0, 10}, {0, -6}}));
    connect(bearingOrifice.a, rotaryCompressor.b) annotation(
      Line(points = {{0, 30}, {0, 46}}));
    connect(pipe1.b, rotaryCompressor.a) annotation(
      Line(points = {{58, -44}, {58, -50}, {24, -50}, {24, 76}, {0, 76}, {0, 66}}));
  connect(pipe1.a, tank.port) annotation(
      Line(points = {{58, -24}, {58, -8}, {74, -8}, {74, -74}, {0, -74}}));
  end test;
end RotaryCompressorSystem;
