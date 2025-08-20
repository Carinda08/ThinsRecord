<template>
  <div class="app-container">
    <div class="header">
      <h1>物品信息记录</h1>
      <p>记录您的物品信息，包括图片和详细信息</p>
    </div>

    <div class="main-content">
      <!-- 图片上传和预览区域 -->
      <div class="image-section">
        <h2>物品图片</h2>
        
        <!-- 图片预览 -->
        <div class="image-preview" v-if="itemImage">
          <img :src="itemImage" alt="物品图片" />
          <button class="remove-btn" @click="removeImage">删除图片</button>
        </div>

        <!-- 图片上传按钮 -->
        <div class="upload-buttons" v-if="!itemImage">
          <button class="upload-btn" @click="openFileInput">
            <span class="icon">📁</span>
            上传图片
          </button>
          <button class="camera-btn" @click="openCamera">
            <span class="icon">📷</span>
            拍摄照片
          </button>
        </div>

        <!-- 隐藏的文件输入 -->
        <input
          ref="fileInput"
          type="file"
          accept="image/*"
          style="display: none"
          @change="handleFileUpload"
        />
      </div>

      <!-- 摄像头模态框 -->
      <div class="camera-modal" v-if="showCamera" @click="closeCamera">
        <div class="camera-content" @click.stop>
          <div class="camera-header">
            <h3>拍摄照片</h3>
            <button class="close-btn" @click="closeCamera">×</button>
          </div>
          
          <div class="camera-view">
            <video ref="videoElement" autoplay muted></video>
            <div class="camera-overlay">
              <div class="focus-frame"></div>
            </div>
          </div>
          
          <div class="camera-controls">
            <button class="capture-btn" @click="capturePhoto">
              <span class="capture-icon">📸</span>
              拍摄
            </button>
            <button class="switch-btn" @click="switchCamera">
              <span class="icon">🔄</span>
              切换摄像头
            </button>
          </div>
        </div>
      </div>

      <!-- 物品信息表单 -->
      <div class="form-section">
        <h2>物品信息</h2>
        <form @submit.prevent="submitForm" class="item-form">
          <div class="form-group">
            <label for="itemName">物品名称 *</label>
            <input
              id="itemName"
              v-model="itemInfo.name"
              type="text"
              placeholder="请输入物品名称"
              required
            />
          </div>

          <div class="form-group">
            <label for="itemCategory">物品类别 *</label>
            <select id="itemCategory" v-model="itemInfo.category" required>
              <option value="">请选择类别</option>
              <option value="电子产品">电子产品</option>
              <option value="服装鞋帽">服装鞋帽</option>
              <option value="家居用品">家居用品</option>
              <option value="图书文具">图书文具</option>
              <option value="运动器材">运动器材</option>
              <option value="其他">其他</option>
            </select>
          </div>

          <div class="form-group">
            <label for="itemFeatures">物品特点</label>
            <textarea
              id="itemFeatures"
              v-model="itemInfo.features"
              placeholder="请描述物品的特点、颜色、材质等"
              rows="3"
            ></textarea>
          </div>

          <div class="form-group">
            <label for="itemUsage">使用方式</label>
            <textarea
              id="itemUsage"
              v-model="itemInfo.usage"
              placeholder="请描述物品的使用方法、注意事项等"
              rows="3"
            ></textarea>
          </div>

          <div class="form-actions">
            <button type="submit" class="submit-btn" :disabled="!isFormValid">
              保存物品信息
            </button>
            <button type="button" class="reset-btn" @click="resetForm">
              重置表单
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- 成功提示 -->
    <div class="success-message" v-if="showSuccess">
      <div class="success-content">
        <span class="success-icon">✅</span>
        <p>物品信息保存成功！</p>
        <button @click="showSuccess = false">确定</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      itemImage: null,
      showCamera: false,
      showSuccess: false,
      itemInfo: {
        name: '',
        category: '',
        features: '',
        usage: ''
      },
      stream: null,
      facingMode: 'user'
    }
  },
  computed: {
    isFormValid() {
      return this.itemInfo.name.trim() && this.itemInfo.category;
    }
  },
  methods: {
    // 文件上传相关方法
    openFileInput() {
      this.$refs.fileInput.click();
    },
    
    handleFileUpload(event) {
      const file = event.target.files[0];
      if (file) {
        this.displayImage(file);
      }
    },

    displayImage(file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        this.itemImage = e.target.result;
      };
      reader.readAsDataURL(file);
    },

    removeImage() {
      this.itemImage = null;
      if (this.$refs.fileInput) {
        this.$refs.fileInput.value = '';
      }
    },

    // 摄像头相关方法
    async openCamera() {
      try {
        this.showCamera = true;
        await this.initializeCamera();
      } catch (error) {
        console.error('无法访问摄像头:', error);
        alert('无法访问摄像头，请检查权限设置');
      }
    },

    async initializeCamera() {
      try {
        if (this.stream) {
          this.stream.getTracks().forEach(track => track.stop());
        }
        
        this.stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: this.facingMode }
        });
        
        if (this.$refs.videoElement) {
          this.$refs.videoElement.srcObject = this.stream;
        }
      } catch (error) {
        console.error('摄像头初始化失败:', error);
        throw error;
      }
    },

    async switchCamera() {
      this.facingMode = this.facingMode === 'user' ? 'environment' : 'user';
      await this.initializeCamera();
    },

    capturePhoto() {
      const canvas = document.createElement('canvas');
      const video = this.$refs.videoElement;
      const context = canvas.getContext('2d');
      
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      
      context.drawImage(video, 0, 0, canvas.width, canvas.height);
      
      canvas.toBlob((blob) => {
        const file = new File([blob], 'captured-photo.jpg', { type: 'image/jpeg' });
        this.displayImage(file);
        this.closeCamera();
      }, 'image/jpeg', 0.8);
    },

    closeCamera() {
      this.showCamera = false;
      if (this.stream) {
        this.stream.getTracks().forEach(track => track.stop());
        this.stream = null;
      }
    },

    // 表单相关方法
    submitForm() {
      if (!this.isFormValid) {
        alert('请填写必填项');
        return;
      }

      // 这里可以添加数据保存逻辑
      console.log('物品信息:', {
        image: this.itemImage,
        ...this.itemInfo
      });

      this.showSuccess = true;
      this.resetForm();
    },

    resetForm() {
      this.itemInfo = {
        name: '',
        category: '',
        features: '',
        usage: ''
      };
      this.removeImage();
    }
  },

  beforeUnmount() {
    this.closeCamera();
  }
}
</script>

<style scoped>
.app-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.header h1 {
  color: #2c3e50;
  margin-bottom: 10px;
  font-size: 2.5rem;
}

.header p {
  color: #7f8c8d;
  font-size: 1.1rem;
}

.main-content {
  display: flex;
  flex-direction: column;
  gap: 30px;
}

.image-section, .form-section {
  background: white;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.image-section h2, .form-section h2 {
  color: #2c3e50;
  margin-bottom: 20px;
  font-size: 1.5rem;
}

.image-preview {
  text-align: center;
  margin-bottom: 20px;
}

.image-preview img {
  max-width: 100%;
  max-height: 300px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.remove-btn {
  background: #e74c3c;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  margin-top: 10px;
  cursor: pointer;
  transition: background 0.3s;
}

.remove-btn:hover {
  background: #c0392b;
}

.upload-buttons {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.upload-btn, .camera-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border: 2px solid #3498db;
  background: white;
  color: #3498db;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s;
}

.upload-btn:hover, .camera-btn:hover {
  background: #3498db;
  color: white;
}

.icon {
  font-size: 1.2rem;
}

.item-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-weight: 600;
  color: #2c3e50;
}

.form-group input,
.form-group select,
.form-group textarea {
  padding: 12px;
  border: 2px solid #e1e8ed;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.3s;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: #3498db;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin-top: 20px;
}

.submit-btn, .reset-btn {
  padding: 12px 30px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s;
}

.submit-btn {
  background: #27ae60;
  color: white;
}

.submit-btn:hover:not(:disabled) {
  background: #229954;
}

.submit-btn:disabled {
  background: #bdc3c7;
  cursor: not-allowed;
}

.reset-btn {
  background: #95a5a6;
  color: white;
}

.reset-btn:hover {
  background: #7f8c8d;
}

/* 摄像头模态框样式 */
.camera-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.camera-content {
  background: white;
  border-radius: 12px;
  padding: 20px;
  max-width: 90vw;
  max-height: 90vh;
  overflow: hidden;
}

.camera-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.camera-header h3 {
  margin: 0;
  color: #2c3e50;
}

.close-btn {
  background: none;
  border: none;
  font-size: 2rem;
  cursor: pointer;
  color: #7f8c8d;
}

.camera-view {
  position: relative;
  margin-bottom: 20px;
}

.camera-view video {
  width: 100%;
  max-width: 500px;
  border-radius: 8px;
}

.camera-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.focus-frame {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 200px;
  height: 200px;
  border: 2px solid #3498db;
  border-radius: 8px;
  opacity: 0.7;
}

.camera-controls {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.capture-btn, .switch-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.3s;
}

.capture-btn {
  background: #e74c3c;
  color: white;
}

.capture-btn:hover {
  background: #c0392b;
}

.switch-btn {
  background: #95a5a6;
  color: white;
}

.switch-btn:hover {
  background: #7f8c8d;
}

.capture-icon {
  font-size: 1.2rem;
}

/* 成功提示样式 */
.success-message {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
}

.success-content {
  background: white;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

.success-icon {
  font-size: 3rem;
  margin-bottom: 15px;
  display: block;
}

.success-content p {
  font-size: 1.2rem;
  color: #2c3e50;
  margin-bottom: 20px;
}

.success-content button {
  background: #27ae60;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
}

.success-content button:hover {
  background: #229954;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .app-container {
    padding: 15px;
  }
  
  .header h1 {
    font-size: 2rem;
  }
  
  .upload-buttons {
    flex-direction: column;
  }
  
  .form-actions {
    flex-direction: column;
  }
  
  .camera-content {
    margin: 20px;
    padding: 15px;
  }
  
  .camera-controls {
    flex-direction: column;
  }
}
</style>