#pragma once
#include "env.h"

class Hopper: public Env
{
public:
    Hopper(bool show_ui): Env((__DIRNAME__ / "assets/hopper.xml").string(), 4, show_ui) {}

    int observe_size() const override { return m->nq - 1 + m->nv; }

    torch::Tensor get_observe() override
    {
        mjtNum *buf = new mjtNum[m->nq - 1 + m->nv];
        std::memcpy(buf, d->qpos + 1, sizeof(mjtNum) * (m->nq - 1));
        std::memcpy(buf + m->nq - 1, d->qvel, sizeof(mjtNum) * m->nv);
        auto ob = torch::from_blob(
            buf, {1, m->nq - 1 + m->nv}, [](void *buf) { delete[](mjtNum *) buf; },
            torch::kFloat64);
        ob = ob.to(torch::kFloat32);
        return ob;
    }

    bool step(torch::Tensor action, double &reward) override
    {
        mjtNum posbefore = d->qpos[0];
        do_step(action);
        mjtNum posafter = d->qpos[0];
        mjtNum height = d->qpos[1];
        mjtNum ang = d->qpos[2];
        double alive_bonus = 1.0;
        reward = (posafter - posbefore) / dt();
        reward += alive_bonus;
        reward -= 1e-3 * at::sum(at::square(action)).item<double>();
        bool done = false;
        return done;
    };
};