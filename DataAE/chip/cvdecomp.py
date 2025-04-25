import numpy as np
import scipy.linalg
import strawberryfields as sf

def symplectic_typical(N, style="xxpp"):
    """
    生成一个典型的辛矩阵
    :param N: 模式数
    :param style: "xxpp" 或 "xpxp"
    :return: 2N x 2N 的辛矩阵
    """
    if style == "xxpp":
        I = np.eye(N)
        O = np.zeros((N, N))
        J = np.block([[O, I], [-I, O]])
        return J
    elif style == "xpxp":
        j2 = np.array([[0, 1], [-1, 0]])
        J = np.kron(np.eye(N), j2)
        return J
    else:
        raise ValueError("[symplectic_typical] style must be either 'xxpp' or 'xpxp'")

def permutation_matrix(N):
    """
    生成将变量排列从 xpxp → xxpp 的置换矩阵 P
    可用于变换变量排列方式：
        M_xxpp = P @ M_xpxp @ P.T
        M_xpxp = P.T @ M_xxpp @ P
    :param N: 模式数
    :return: 置换矩阵 P (2N x 2N)
    """
    P = np.zeros((2*N, 2*N))
    for i in range(N):
        P[i, 2*i] = 1
        P[N + i, 2*i + 1] = 1
    return P

def is_symplectic(S, style="xxpp", tol=1e-8, verbose=False):
    """
    检查矩阵 S 是否是辛矩阵，即 S.T @ J @ S ≈ J
    """
    if not isinstance(S, np.ndarray) or S.ndim != 2 or S.shape[0] != S.shape[1] or S.shape[0] % 2 != 0:
        raise ValueError("[is_symplectic] S 必须是偶数阶方阵")
    N = S.shape[0] // 2
    J = symplectic_typical(N, style=style)
    left = S.T @ J @ S
    is_symp = np.allclose(left, J, atol=tol)
    if verbose:
        print("S^T J S - J =\n", left - J)
    return is_symp

def is_physical_covariance(V, style="xxpp", hbar=1.0, tol=1e-10, verbose=False):
    N = V.shape[0] // 2
    J = symplectic_typical(N, style=style)
    matrix = V + 1j * hbar / 2 * J
    eigvals = np.linalg.eigvals(matrix)
    
    if verbose:
        print("最低特征值实部:", np.min(np.real(eigvals)))

    return np.all(np.real(eigvals) >= -tol)

def symplectic_eigenvalues(V, style="xxpp", hbar=1.0):
    N = V.shape[0] // 2
    J = symplectic_typical(N, style=style)
    eigvals = np.linalg.eigvals(1j * J @ V)
    return np.sort(np.abs(eigvals))[::2]

def is_physical_by_symplectic(V, style="xxpp", hbar=1.0, tol=1e-10, verbose=False):
    eigv = symplectic_eigenvalues(V, style=style, hbar=hbar)
    if verbose:
        print("辛特征值:", eigv)
        print("最低特征值:", np.min(eigv))
    return np.all(eigv >= hbar / 2 - tol)

# def decomp_williamson1(V, verbose=False):
    """
    威廉姆森分解：V = S D S^T
    返回 D（对角矩阵）和 S（辛矩阵）
    """
    if not isinstance(V, np.ndarray) or V.ndim != 2 or V.shape[0] != V.shape[1] or V.shape[0] % 2 != 0:
        raise ValueError("[decomp_williamson] 输入必须是偶数阶方阵")

    N = V.shape[0] // 2
    J = symplectic_typical(N, style="xxpp")

    # 计算辛特征值（对角项 ν_i）
    iJV = 1j * J @ V
    eigvals = np.linalg.eigvals(iJV)
    symplectic_eigs = np.sort(np.abs(eigvals))[::2]  # 保留非简并值

    # 构造 D = diag(ν_1, ..., ν_N, ν_1, ..., ν_N)
    D = np.diag(np.repeat(symplectic_eigs, 2))

    # 构造 S 使用 scipy 的 canonical form 方法
    S = scipy.linalg.sqrtm(V) @ scipy.linalg.inv(scipy.linalg.sqrtm(D))

    if verbose:
        print("辛特征值 ν_i:", symplectic_eigs)
        print("D:\n", D)
        print("S^T J S - J =\n", S.T @ J @ S - J)

    return D, S

# def decomp_williamson2(V, style="xxpp", verbose=False, tol=1e-10):
    """
    严格的威廉姆森分解 V = S D S^T
    返回对角辛谱 D 和辛变换 S，使得 S^T J S = J
    """
    if not isinstance(V, np.ndarray) or V.ndim != 2 or V.shape[0] != V.shape[1] or V.shape[0] % 2 != 0:
        raise ValueError("Input V must be a real, symmetric, even-dimensional matrix.")

    if not np.allclose(V, V.T, atol=tol):
        raise ValueError("V must be symmetric.")

    N = V.shape[0] // 2
    J = symplectic_typical(N, style=style)

    # 1. 构造 J V
    JV = J @ V

    # 2. 求解本征对
    eigvals, eigvecs = np.linalg.eig(JV)
    idx = np.argsort(np.abs(np.real(eigvals)))
    eigvals = eigvals[idx]
    eigvecs = eigvecs[:, idx]

    # 3. 只取正的共轭成对本征值
    pos_eigs = []
    pos_vecs = []
    for i in range(len(eigvals)):
        if np.imag(eigvals[i]) > 0:
            pos_eigs.append(np.imag(eigvals[i]))
            pos_vecs.append(np.real(eigvecs[:, i]))

    nu = np.array(pos_eigs)  # 辛特征值
    D = np.diag(np.concatenate([nu, nu]))

    # 4. 构造辛正则基
    W = np.stack(pos_vecs, axis=1)
    W_tilde = J @ W
    S = np.concatenate([W, W_tilde], axis=1)

    # 5. 使用 V 恢复 S 的缩放，使得 V = S D S^T
    # 构造正交化基
    try:
        L = scipy.linalg.sqrtm(V)
        S = L @ np.linalg.inv(scipy.linalg.sqrtm(D))
    except Exception as e:
        raise RuntimeError("数值计算失败") from e
    
    if verbose:
        print("辛特征值 ν_i:", nu)
        print("D:\n", D)
        print("S^T J S - J =\n", S.T @ J @ S - J)

    return D, S

def williamson_decomposition(V, style="xxpp", verbose=False, tol=1e-10):
    """
    统一的威廉姆森分解：V = S D S^T
    支持 xxpp 或 xpxp 排列格式
    返回：
      D: 辛谱，对角矩阵（格式取决于 style）
      S: 辛矩阵
    """
    if not isinstance(V, np.ndarray) or V.ndim != 2 or V.shape[0] != V.shape[1] or V.shape[0] % 2 != 0:
        raise ValueError("V must be a symmetric positive definite matrix of even size.")
    if not np.allclose(V, V.T, atol=tol):
        raise ValueError("V must be symmetric.")

    N = V.shape[0] // 2
    J = symplectic_typical(N, style=style)

    # Step 1: i J V 的特征值
    iJV = 1j * J @ V
    eigvals = np.linalg.eigvals(iJV)
    symplectic_eigs = np.sort(np.abs(eigvals))[::2]  # 非简并

    # Step 2: 构造标准辛谱 D
    if style == "xxpp":
        D = np.diag(np.tile(symplectic_eigs, 2)) # [v1, v2, ..., v1, v2, ...]
    elif style == "xpxp":
        D = np.diag(np.repeat(symplectic_eigs, 2)) # [v1, v1, ..., v2, v2, ...]
    else:
        raise ValueError("Unknown style for Williamson decomposition.")

    # Step 3: 构造 S
    sqrtV = scipy.linalg.sqrtm(V)
    sqrtD = scipy.linalg.sqrtm(D)
    S = sqrtV @ np.linalg.inv(sqrtD)

    # # Step 4: 根据风格变换变量排列（如果 style 是 xpxp）
    # if style == "xpxp":
    #     P = permutation_matrix(N)
    #     S = P.T @ S  # 把 S 从 xxpp -> xpxp
    #     D = P.T @ D @ P

    if verbose:
        print("Style:", style)
        print("Symplectic eigenvalues ν_i:", symplectic_eigs)
        print("D =\n", D)
        print("S =\n", S)
        J_check = S.T @ J @ S
        print("S^T J S - J =\n", J_check - J)

    return D, S

def strict_williamson_decomposition(V, style="xxpp", tol=1e-10, verbose=False):
    """
    严格的威廉姆森分解：将正定协方差矩阵 V 分解为
         V = S D S^T
    其中 S 满足辛条件 S^T J S = J。
    
    算法基于下面的公式：
         S = V^(1/2) * ( V^(1/2) J V^(1/2) )^(-1/2)
         D = S^(-1) V (S^(-1))^T
         
    参数：
      V      : (2N x 2N) 实对称正定矩阵（协方差矩阵）
      style  : "xxpp" 或 "xpxp"，决定 J 的形式
      tol    : 数值判断容差
      verbose: 如果为 True，则打印中间调试信息
      
    返回：
      S      : 计算得到的辛矩阵，理论上应满足 S^T J S = J
      D      : 对角辛谱矩阵，排列形式将由 style 决定
    """
    # 检查 V 是否对称
    if not np.allclose(V, V.T, atol=tol):
        raise ValueError("V must be symmetric.")
    
    # 计算 V 的唯一正定平方根
    X = scipy.linalg.sqrtm(V)
    if np.max(np.abs(np.imag(X))) < tol:
        X = np.real(X)
    
    N = V.shape[0] // 2
    J = symplectic_typical(N, style=style)
    
    # 计算 A = V^(1/2) J V^(1/2)
    A = X @ J @ X
    
    # 求 A 的逆平方根：即计算 (A)^(-1/2)
    # 注意 A 是反对称矩阵，理论上其谱为纯虚数，但数值上可能存在小的实部误差
    A_sqrt = scipy.linalg.sqrtm(A)
    if np.max(np.abs(np.imag(A_sqrt))) < tol:
        A_sqrt = np.real(A_sqrt)
    # 取逆：注意不直接求 A^(-1/2) = inv(sqrtm(A))
    A_inv_sqrt = np.linalg.inv(A_sqrt)
    # 计算 S
    S = X @ A_inv_sqrt

    # 验证 S 是否为辛矩阵：应满足 S^T J S = J
    if verbose:
        J_check = S.T @ J @ S
        print("S^T J S - J =\n", J_check - J)
    
    # 计算 D = S^(-1) V S^(-T)
    Sinv = np.linalg.inv(S)
    D = Sinv @ V @ Sinv.T

    # 对于排列风格的控制，通常 D 的排列可通过 tile/repeat 重新排序，
    # 但由于我们是从严格分解中获得 D，
    # 此时 D 的理论形式应为 block-diag(ν1 I_2, ..., νN I_2).
    if verbose:
        print("D =\n", D)
        print("S =\n", S)
    
    return D, S

def are_symplectically_equivalent(S1, S2, style="xxpp", tol=1e-8, verbose=False):
    """
    判断两个辛矩阵是否辛等价：是否存在辛矩阵 R，使得 S2 = S1 @ R
    """
    if S1.shape != S2.shape:
        return False

    N = S1.shape[0] // 2
    J = symplectic_typical(N, style)

    # 计算 R = S1^{-1} S2
    R = np.linalg.inv(S1) @ S2

    # 判断 R 是否为辛矩阵
    check = R.T @ J @ R
    is_symplectic = np.allclose(check, J, atol=tol)

    if verbose:
        print("R = S1⁻¹ S2 =\n", R)
        print("Rᵀ J R - J =\n", check - J)

    return is_symplectic

def bloch_messiah_decomp(S, tol=1e-10):
    """
    对一个辛矩阵 S 执行 Bloch–Messiah 分解:
        S = O1 @ Sigma @ O2
    返回:
        O1, Sigma, O2
    """
    if not is_symplectic(S):
        raise ValueError("S is not symplectic")

    U, Sigma_vals, Vh = np.linalg.svd(S)

    # 构造辛兼容的对角矩阵：Sigma = diag(s_1, 1/s_1, s_2, 1/s_2, ...)
    N = S.shape[0] // 2
    Sigma_matrix = np.zeros_like(S)
    for i in range(N):
        s = Sigma_vals[2 * i]
        Sigma_matrix[2 * i, 2 * i] = s
        Sigma_matrix[2 * i + 1, 2 * i + 1] = 1 / s

    # Vh 是 V^T，我们需要 V
    V = Vh.T
    O1 = U
    O2 = V.T

    return O1, Sigma_matrix, O2

def reconstruct_from_bmd(O1, Sigma, O2):
    return O1 @ Sigma @ O2

def bloch_messiah_channel(K, N_noise, tol=1e-10):
    """
    将高斯通道表示为 Bloch-Messiah 分解 + 噪声项：
        K V K^T + N = (O1 Σ O2) V (O1 Σ O2)^T + N
    输入:
        K: 高斯通道的线性变换矩阵 (2N x 2N)
        N_noise: 噪声协方差矩阵 (2N x 2N)
    返回:
        O1, Sigma, O2, N_noise
    """
    U, s, Vh = np.linalg.svd(K)
    V = Vh.T
    Sigma = np.zeros_like(K)
    for i in range(len(s)):
        Sigma[i, i] = s[i]

    O1 = U
    O2 = V.T

    return O1, Sigma, O2, N_noise

def apply_bloch_messiah_channel(V_in, O1, Sigma, O2, N):
    """
    应用 Bloch-Messiah + 噪声形式的通道到输入协方差矩阵 V_in 上
    """
    K = O1 @ Sigma @ O2
    return K @ V_in @ K.T + N

def invert_loss_channel(V_out, eta, hbar=1.0):
    """
    已知输出协方差矩阵和损耗率，反推输入态（假设环境为真空态）
    :param V_out: 输出协方差矩阵
    :param eta: 透过率 (0 < eta <= 1)
    :param hbar: 量子单位 (默认1)
    :return: V_in (估计的输入协方差矩阵)
    """
    if not (0 < eta <= 1):
        raise ValueError("η 应该在 (0, 1] 之间")
    n = V_out.shape[0]
    I = np.eye(n)
    V_env = (hbar / 2) * I
    V_in = (V_out - (1 - eta) * V_env) / eta
    return V_in

def invert_gaussian_channel(V_out, K, N):
    """
    高斯通道反演：已知输出协方差矩阵、K 和 N，求输入态
    V_out = K V_in K^T + N
    解得：V_in = K^{-1} (V_out - N) (K^{-1})^T
    """
    K_inv = np.linalg.inv(K)
    return K_inv @ (V_out - N) @ K_inv.T

def two_mode_squeezed_V(r):
    """
    双模压缩态协方差矩阵（变量排列为 xxpp）
    ħ = 1
    :param r: 压缩参数
    :return: 2x2 协方差矩阵 V
    """
    ch = np.cosh(2 * r)
    sh = np.sinh(2 * r)
    
    V = 0.5 * np.array([
        [ ch,  sh,   0,   0],
        [ sh,  ch,   0,   0],
        [  0,   0,  ch, -sh],
        [  0,   0, -sh,  ch]
    ])
    return V

def williamson(V, tol=1e-11):
    r"""Williamson decomposition of positive-definite (real) symmetric matrix.

    See :ref:`williamson`.

    Note that it is assumed that the symplectic form is

    .. math:: \Omega = \begin{bmatrix}0&I\\-I&0\end{bmatrix}

    where :math:`I` is the identity matrix and :math:`0` is the zero matrix.

    See https://math.stackexchange.com/questions/1171842/finding-the-symplectic-matrix-in-williamsons-theorem/2682630#2682630

    Args:
        V (array[float]): positive definite symmetric (real) matrix
        tol (float): the tolerance used when checking if the matrix is symmetric: :math:`|V-V^T| \leq` tol

    Returns:
        tuple[array,array]: ``(Db, S)`` where ``Db`` is a diagonal matrix
            and ``S`` is a symplectic matrix such that :math:`V = S^T Db S`
    """
    (n, m) = V.shape

    if n != m:
        raise ValueError("The input matrix is not square")

    diffn = np.linalg.norm(V - np.transpose(V))

    if diffn >= tol:
        raise ValueError("The input matrix is not symmetric")

    if n % 2 != 0:
        raise ValueError("The input matrix must have an even number of rows/columns")

    n = n // 2
    omega = sympmat(n)
    vals = np.linalg.eigvalsh(V)

    for val in vals:
        if val <= 0:
            raise ValueError("Input matrix is not positive definite")

    Mm12 = sqrtm(np.linalg.inv(V)).real
    r1 = Mm12 @ omega @ Mm12
    s1, K = schur(r1)
    X = np.array([[0, 1], [1, 0]])
    I = np.identity(2)
    seq = []

    # In what follows I construct a permutation matrix p  so that the Schur matrix has
    # only positive elements above the diagonal
    # Also the Schur matrix uses the x_1,p_1, ..., x_n,p_n  ordering thus I use rotmat to
    # go to the ordering x_1, ..., x_n, p_1, ... , p_n

    for i in range(n):
        if s1[2 * i, 2 * i + 1] > 0:
            seq.append(I)
        else:
            seq.append(X)

    p = block_diag(*seq)
    Kt = K @ p
    s1t = p @ s1 @ p
    dd = xpxp_to_xxpp(s1t)
    perm_indices = xpxp_to_xxpp(np.arange(2 * n))
    Ktt = Kt[:, perm_indices]
    Db = np.diag([1 / dd[i, i + n] for i in range(n)] + [1 / dd[i, i + n] for i in range(n)])
    S = Mm12 @ Ktt @ sqrtm(Db)
    return Db, np.linalg.inv(S).T
