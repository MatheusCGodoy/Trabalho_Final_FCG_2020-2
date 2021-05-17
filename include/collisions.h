#include <cstdlib>
#include <iostream>
#include "Objects.h"

bool BOX_collision(const SceneObject& A, const SceneObject& B);

bool ClipLine(int dim, const SceneObject& A, const glm::vec4 vec_origin, const glm::vec4 vec_end, float& f_low, float& f_high);

bool LINE_collision(const SceneObject& A, const glm::vec4 vec_origin, const glm::vec4 vec_end);
