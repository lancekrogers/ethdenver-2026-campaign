import { Composition } from "remotion";
import { ObeyDemo } from "./ObeyDemo";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="obey-demo"
        component={ObeyDemo}
        width={1920}
        height={1080}
        fps={30}
        durationInFrames={5760}
      />
    </>
  );
};
