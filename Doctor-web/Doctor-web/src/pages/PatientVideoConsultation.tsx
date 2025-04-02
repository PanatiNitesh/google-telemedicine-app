import React, { useEffect, useRef, useState } from 'react';
import { db } from '../firebase'; // Import Firestore instance
import { collection, doc, updateDoc, onSnapshot, addDoc, query, orderBy } from 'firebase/firestore';
import { PhoneOff, Mic, MicOff, Video, VideoOff } from 'lucide-react';

interface PatientVideoConsultationProps {
  doctorId: string;
  userId: string;
}

const PatientVideoConsultation: React.FC<PatientVideoConsultationProps> = ({ doctorId, userId }) => {
  const [peerConnection, setPeerConnection] = useState<RTCPeerConnection | null>(null);
  const [isConnected, setIsConnected] = useState<boolean>(false);
  const [isMuted, setIsMuted] = useState<boolean>(false);
  const [isVideoOff, setIsVideoOff] = useState<boolean>(false);
  const [localStream, setLocalStream] = useState<MediaStream | null>(null);
  const [connectionStatus, setConnectionStatus] = useState<string>('Waiting for doctor...');

  const localVideoRef = useRef<HTMLVideoElement>(null);
  const remoteVideoRef = useRef<HTMLVideoElement>(null);
  const callId = `${doctorId}_${userId}`; // Unique call ID for Firestore

  const config = {
    iceServers: [
      { urls: 'stun:stun.l.google.com:19302' },
      { urls: 'stun:stun1.l.google.com:19302' },
    ],
  };

  const toggleMute = () => {
    if (localStream) {
      const audioTracks = localStream.getAudioTracks();
      audioTracks.forEach((track) => (track.enabled = !isMuted));
      setIsMuted((prev) => !prev);
    }
  };

  const toggleVideo = () => {
    if (localStream) {
      const videoTracks = localStream.getVideoTracks();
      videoTracks.forEach((track) => (track.enabled = !isVideoOff));
      setIsVideoOff((prev) => !prev);
    }
  };

  useEffect(() => {
    const pc = new RTCPeerConnection(config);
    setPeerConnection(pc);

    // Get local stream (patient's camera/mic)
    navigator.mediaDevices
      .getUserMedia({ video: true, audio: true })
      .then((stream) => {
        console.log('Patient: Local stream acquired');
        setLocalStream(stream);
        if (localVideoRef.current) localVideoRef.current.srcObject = stream;
        stream.getTracks().forEach((track) => pc.addTrack(track, stream));
      })
      .catch((err) => {
        console.error('Patient: Error accessing media devices:', err);
        setConnectionStatus('Camera/Mic access denied');
      });

    // Handle ICE candidates
    pc.onicecandidate = (event) => {
      if (event.candidate) {
        console.log('Patient: Sending ICE candidate');
        addDoc(collection(db, 'calls', callId, 'messages'), {
          type: 'candidate',
          candidate: event.candidate.toJSON(),
          sender: userId,
          role: 'patient',
          timestamp: new Date().toISOString(),
        });
      }
    };

    // Handle remote stream (doctor's video)
    pc.ontrack = (event) => {
      console.log('Patient: Received remote stream');
      if (remoteVideoRef.current) {
        remoteVideoRef.current.srcObject = event.streams[0];
        setIsConnected(true);
        setConnectionStatus('Connected');
      }
    };

    // Monitor connection state
    pc.onconnectionstatechange = () => {
      console.log('Patient: Connection state changed to', pc.connectionState);
      switch (pc.connectionState) {
        case 'connected':
          setConnectionStatus('Connected');
          setIsConnected(true);
          break;
        case 'disconnected':
        case 'failed':
          setConnectionStatus('Connection lost');
          setIsConnected(false);
          break;
        case 'closed':
          setConnectionStatus('Call ended');
          setIsConnected(false);
          break;
      }
    };

    // Firestore listener for signaling messages
    const callDocRef = doc(db, 'calls', callId);
    const messagesQuery = query(collection(db, 'calls', callId, 'messages'), orderBy('timestamp'));

    console.log('Patient: Setting up Firestore listener for messages');
    const unsubscribeMessages = onSnapshot(messagesQuery, (snapshot) => {
      console.log('Patient: Firestore snapshot received, changes:', snapshot.docChanges().length);
      snapshot.docChanges().forEach((change) => {
        if (change.type === 'added') {
          const data = change.doc.data();
          console.log('Patient: New message received:', data);
          if (data.sender !== userId) {
            console.log('Patient: Processing message from doctor');
            handleSignalingMessage(data, pc);
          }
        }
      });
    }, (error) => {
      console.error('Patient: Firestore listener error:', error);
    });

    const unsubscribeCall = onSnapshot(callDocRef, (snapshot) => {
      if (!snapshot.exists() || snapshot.data()?.status === 'ended') {
        console.log('Patient: Call ended or document deleted');
        endCall(pc);
      }
    });

    return () => {
      unsubscribeMessages();
      unsubscribeCall();
      endCall(pc);
    };
  }, [doctorId, userId]);

  const handleSignalingMessage = async (data: any, pc: RTCPeerConnection) => {
    try {
      console.log('Patient: Received signaling message:', data);
      switch (data.type) {
        case 'offer':
          console.log('Patient: Processing offer from doctor:', data.sdp);
          await pc.setRemoteDescription(new RTCSessionDescription({ type: 'offer', sdp: data.sdp }));
          console.log('Patient: Creating answer...');
          const answer = await pc.createAnswer();
          console.log('Patient: Setting local description with answer:', answer);
          await pc.setLocalDescription(answer);
          console.log('Patient: Sending answer to Firestore...');
          const answerRef = await addDoc(collection(db, 'calls', callId, 'messages'), {
            type: 'answer',
            sdp: answer.sdp,
            sender: userId,
            role: 'patient',
            timestamp: new Date().toISOString(),
          });
          console.log('Patient: Answer sent successfully, message ID:', answerRef.id);
          break;
        case 'candidate':
          console.log('Patient: Adding ICE candidate from doctor:', data.candidate);
          await pc.addIceCandidate(new RTCIceCandidate(data.candidate));
          console.log('Patient: ICE candidate added successfully');
          break;
        default:
          console.log('Patient: Unknown message type:', data.type);
      }
    } catch (e) {
      console.error('Patient: Signaling error:', e);
    }
  };

  const endCall = (pc: RTCPeerConnection | null) => {
    if (pc) pc.close();
    if (localStream) localStream.getTracks().forEach((track) => track.stop());
    if (localVideoRef.current) localVideoRef.current.srcObject = null;
    if (remoteVideoRef.current) remoteVideoRef.current.srcObject = null;

    updateDoc(doc(db, 'calls', callId), {
      status: 'ended',
      endedBy: userId,
      endedAt: new Date().toISOString(),
    });

    setIsConnected(false);
    setConnectionStatus('Call ended');
  };

  return (
    <div className="flex flex-col min-h-screen bg-gray-50">
      <header className="bg-blue-600 text-white py-4 px-6 shadow-md">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold">Patient Video Consultation</h1>
          <span
            className={`px-3 py-1 rounded-full text-sm font-medium ${
              isConnected ? 'bg-green-500' : 'bg-yellow-500'
            }`}
          >
            {connectionStatus}
          </span>
        </div>
      </header>

      <main className="flex-1 p-6">
        <div className="max-w-6xl mx-auto">
          <div className="relative mb-6 bg-black rounded-xl overflow-hidden aspect-video shadow-xl">
            <video ref={remoteVideoRef} autoPlay playsInline className="w-full h-full object-cover" />
            {!isConnected && (
              <div className="absolute inset-0 flex items-center justify-center bg-gray-900 bg-opacity-70">
                <div className="text-center text-white">
                  <p className="text-xl mb-4">{connectionStatus}</p>
                </div>
              </div>
            )}
            <div className="absolute top-4 right-4 w-48 h-36 bg-gray-800 rounded-lg overflow-hidden shadow-lg border-2 border-white">
              <video
                ref={localVideoRef}
                autoPlay
                playsInline
                muted
                className={`w-full h-full object-cover ${isVideoOff ? 'opacity-0' : ''}`}
              />
              {isVideoOff && (
                <div className="absolute inset-0 flex items-center justify-center bg-gray-800">
                  <span className="text-white">Camera Off</span>
                </div>
              )}
            </div>
          </div>

          <div className="flex justify-center space-x-4">
            <button
              onClick={toggleMute}
              className={`flex items-center justify-center w-12 h-12 rounded-full ${
                isMuted ? 'bg-red-500 hover:bg-red-600' : 'bg-blue-500 hover:bg-blue-600'
              } text-white transition`}
            >
              {isMuted ? <MicOff size={20} /> : <Mic size={20} />}
            </button>
            <button
              onClick={() => endCall(peerConnection)}
              className="flex items-center justify-center w-16 h-16 rounded-full bg-red-500 hover:bg-red-600 text-white transition"
            >
              <PhoneOff size={24} />
            </button>
            <button
              onClick={toggleVideo}
              className={`flex items-center justify-center w-12 h-12 rounded-full ${
                isVideoOff ? 'bg-red-500 hover:bg-red-600' : 'bg-blue-500 hover:bg-blue-600'
              } text-white transition`}
            >
              {isVideoOff ? <VideoOff size={20} /> : <Video size={20} />}
            </button>
          </div>
        </div>
      </main>
    </div>
  );
};

export default PatientVideoConsultation;