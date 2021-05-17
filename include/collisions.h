#include <cstdlib>
#include <iostream>
#include "Objects.h"

bool BOX_collision(const SceneObject& A, const SceneObject& B);

bool ClipLine(int dim, const SceneObject& A, const glm::vec4 vec_origin, const glm::vec4 vec_end, const glm::mat4 model, float& f_low, float& f_high);

bool LINE_collision(const SceneObject& A, const glm::vec4 vec_origin, const glm::vec4 vec_end, const glm::mat4 model);

bool pointAABB_collision(const SceneObject& A, const glm::vec4 p, const glm::mat4 model);

bool pointAABB_collision2(const SceneObject& A, const glm::vec4 p, const glm::mat4 model);
