<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<!DOCTYPE html>
<html>

<head>

   <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
   <script type="text/javascript">
   <%-- 여기에 스크립트 넣어주세요. --%>

      // jstl foreach 쓸때는 codeMap, 자바스크립트에서는 codeMapJsonObj 쓸것.
      //console.log('${codeMap.CLASSID}');
      //console.log('${codeMapJsonObj.CLASSID}');

      $(document).ready(function() {
         // format이 phone일경우 하이픈 제거해서 가져옴.
         console.log("format phone get", $M.getValue("hp_no"));

         // foramt이 decimal일 경우 , 를 제외하고 가져옴(소수점은 유지)
         console.log("format decimal get", $M.getValue("jpy_basic"));

         // dateFormat이 있을경우 dateFormat을 제거해서 가져옴.
         console.log("dateFormat get", $M.getValue("breg_open_dt"));

         fnInit();

      });

      // [15124] 퇴사자 업무 이관 팝업 - 김경빈
      function goRetireYiguan() {
          var param = {
              s_mem_no : $M.getValue("retire_mem_no")
          }
          openRetireYiguanPanel('setRetireYiguanPanel', $M.toGetParam(param));
      }

      // [15124] 퇴사자 업무 이관 팝업 데이터 콜백 - 김경빈
      function setRetireYiguanPanel(data) {
          alert(JSON.stringify(data));
      }

      // 사업자정보조회 or 사업자명세조회에서 사업자등록 후 해당 데이터 callback
      // 사업자정보조회 결과 test
      function fnSetBregInfo(row) {
         alert(JSON.stringify(row));
      }

      // 사업자정보조회 or 사업자명세조회에서 사업자등록 후 해당 데이터 callback
  	  // 사업자명세조회
      function fnSetBregSpec(row) {
         alert(JSON.stringify(row));
      }

      // 고객조회 결과 test
      function setCustInfo(row) {
         alert(JSON.stringify(row));
      }

      // 템플릿선택 결과 test
      function setTemplateInfo(row) {
         alert(JSON.stringify(row));
      }

      // 담당자조회 결과 test
      function setSaleAreaInfo(row) {
         alert(JSON.stringify(row));
      }

      // 부품조회 결과 test
      function setPartInfo(row) {
         alert(JSON.stringify(row));
      }

      // 요청 결과
      function setPartRequestInfo(row) {
    	  alert(JSON.stringify(row));
      }

      //발주 요청
      function setOrderRequestPartInfo(row) {
    	  alert(JSON.stringify(row));
      }

      // 직원조회 결과 test
      function fnSetMemberInfo(row) {
         alert(JSON.stringify(row));
      }

      //홍보파일 참조 test
      function setPromoteFileInfo(row) {
         alert(JSON.stringify(row));
      }

      //견본문자 test
      function setSampleSMSInfo(row) {
    	 alert(JSON.stringify(row));
      }

      //모델조회 test
      function setModelInfo(row) {
         alert(JSON.stringify(row));
      }

      //문자 발송내역 조회 test
      function setSendSMSInfo(row) {
         alert(JSON.stringify(row));
      }
      //매입처 조회 test
      function setSearchClientInfo(row) {
         alert(JSON.stringify(row));
      }

      //업무디비 분류선택
      function setSearchWorkDbDir(row) {
         alert(JSON.stringify(row));
      }

      // 거래시필수확인사항
      function fnCheckRequired() {
		 var param = {
    	 	"cust_no" : $M.getValue("s_cr_cust_no")
    	 };
		 openCheckRequiredPanel('setCheckRequired', $M.toGetParam(param));
      }

      // 거래시필수확인사항
      function setCheckRequired(row) {
         alert(JSON.stringify(row));
      }

      // 주소팝업 test
      function fnJusoBiz(data) {
         alert(JSON.stringify(data));
      }

      // 주소팝업 test
      function setModelInfo(data) {
         alert(JSON.stringify(data));
      }

      // 유무상 부품관리
      function fnSetFreeAndPaidMachinePart(data) {
         alert(JSON.stringify(data));
      }

      // 추가품목선별
      function fnSetAddMachinePartItem(data) {
         alert(JSON.stringify(data));
      }

      // 콤보 셋밸류 test
      function fnSetValue() {
     	 // 멀티일때
          $M.setValue("group_code", ["CLASSID", "PART_GROUP"]);

     	 // 싱글일때
     	 // $M.setValue("group_code", "CLASSID");
      }

      // 콤보 겟밸류 test
      function fnGetValue() {
         alert($M.getValue("group_code"));
      }

      // 결재처리 결과
      function fnSetApproval(result) {
         alert(JSON.stringify(result));
      }

      // 입출고내역 결과 test
      function fnSetInoutPartInfo(row) {
         alert(JSON.stringify(row));
      }

      // 사업자명세조회
      function fnSearchBregSpec() {
    	  var param = {
    			 's_cust_no' : $M.getValue('cust_no')
    	  };
    	  openSearchBregSpecPanel('fnSetBregSpec', $M.toGetParam(param));
      }

      // 사업자정보조회
      function fnSearchBregInfo() {
    	  var param = {
    			 's_breg_no' : $M.getValue('breg_name')
    	  };
    	  openSearchBregInfoPanel('fnSetBregInfo', $M.toGetParam(param));
      }


	  // 문자발송내역 팝업
	  function goSendSmsHis() {
	  	var params = {
	    		"receiver_name" : $M.getValue("receiver_name"),
	    		"phone_no" 		: $M.getValue("phone_no"),
	    };

			openSearchSendSMSPanel('setSendSMSInfo', $M.toGetParam(params));
	  }

      // 문자발송
	  function fnSendSms() {
		   var param = {
				   'name' : $M.getValue('name'),
				   'hp_no' : $M.getValue('hp_no'),
				   'sms_send_type_cd' : $M.getValue('sms_send_type_cd'),
				   'req_sendtarger_yn' : $M.getValue('req_sendtarger_yn'),
				   'req_key' : $M.getValue('req_key')
		   	};
	   		openSendSmsPanel($M.toGetParam(param));
	  }

      // 부품조회(단일)
      function fnSearchPart() {
    	  var param = {
    			 's_part_no' : $M.getValue('part_no'),
    			 's_warehouse_cd' : $M.getValue('warehouse_cd'),
    			 's_only_warehouse_yn' : $M.getValue('only_warehouse_yn'),
    			 's_part_mng_cd' : $M.getValue('s_part_mng_cd'),
    			 's_cust_no' : $M.getValue('part_cust_no')
    	  };
    	  openSearchPartPanel('setPartInfo', 'N', $M.toGetParam(param));
      }

      // 부품조회(다중)
      function fnSearchPartMulti() {
    	  var param = {
     			 's_part_no' : $M.getValue('part_no'),
    			 's_warehouse_cd' : $M.getValue('warehouse_cd'),
    			 's_only_warehouse_yn' : $M.getValue('only_warehouse_yn'),
    			 's_part_mng_cd' : $M.getValue('s_part_mng_cd'),
    			 's_cust_no' : $M.getValue('part_cust_no')
    	  };
    	  openSearchPartPanel('setPartInfo', 'Y', $M.toGetParam(param));
      }

      // 이메일 발송 팝업 line 로그인 필요
      function fnSendMail() {
    	  var param = {
    			 'to' 		: $M.getValue('user_email'),
    			 'subject' 	: $M.getValue('email_title'),
    			 'body' 	: $M.getValue('email_body'),
     	  };
         openSendEmailPanel($M.toGetParam(param));
      }

 	  // 결재처리
      function fnApproval() {
    	  var param = {
     			 'mem_appr_seq' : $M.getValue('mem_appr_seq')
     	  };
    	  openApprPanel('fnSetApproval', $M.toGetParam(param));
      }

      // 발주요청조회
      function fnOrderRequestPart() {
    	  var param = {
    		's_cust_no' : $M.getValue('s_req_part_cust_no')
    	  };

    	  openOrderRequestPartPanel('setOrderRequestPartInfo', $M.toGetParam(param));
      }

      // 입출고내역
      function fnInoutPartInfo() {
    	  var param = {
    		'part_no' : $M.getValue('in_part_no')
    	  };

    	  openInoutPartPanel('fnSetInoutPartInfo', $M.toGetParam(param));
      }

		// 부품이동요청
		function goTransPart() {
			var param = {
				'part_no' : $M.getValue('trans_part_no')

			};
			openTransPartPanel('setMovePartInfo', $M.toGetParam(param));
		}

		// 부품발주요청
		function fnOrderPart() {
			var param = {
				's_part_no' : $M.getValue('p_part_no')

			};
			openOrderPartPanel('setPartRequestInfo', $M.toGetParam(param))
		}

		// 직원조회
		function goMemberInfo() {
			// s_agency_exclude_yn 값이 없으면 Default = 'Y'
			var param = {
					's_org_code' : $M.getValue('s_org_code'),
					's_agency_exclude_yn' : 'N'
				};
			openSearchMemberPanel('fnSetMemberInfo', $M.toGetParam(param))
		}

		// 유무상부품조회
		function goFreeAndPaidMachinePart() {
			var param = {
					'machine_plant_seq' : $M.getValue('machine_plant_seq'),
					'page_type' : $M.getValue('page_type')
				};
			openFreeAndPaidMachinePart('fnSetFreeAndPaidMachinePart', $M.toGetParam(param))
		}

		// 추가품목선별
		function goAddMachinePartItem() {
			var param = {
					'machine_plant_seq' : $M.getValue('machine_plant_seq'),
				};
			openAddMachinePartItem('fnSetAddMachinePartItem', $M.toGetParam(param))
		}

		// 모델조회(단일)
		function goModelInfo() {
			var param = {
			};
			openSearchModelPanel('setModelInfo', 'N', $M.toGetParam(param));
		}

		// 모델조회(다중)
		function goModelInfoMulti() {
			var param = {
			};
			openSearchModelPanel('setModelInfo', 'Y', $M.toGetParam(param));
		}

		// 공통견본문자
		function fnSearchSampleCommSMS() {
			var param = {

			};
			openSearchSampleSMSPanel('setSampleSMSInfo', 'comm', $M.toGetParam(param));
		}

		// 개별견본문자
		function fnSearchSampleIndiSMS() {
			var param = {

			};
			openSearchSampleSMSPanel('setSampleSMSInfo', 'indi', $M.toGetParam(param));
		}

		// 매입처조회
		function fnSearchClientComm() {
			var param = {

			};
			openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
		}

		// 매입처조회(와이드)
		function fnSearchClientWide() {
			var param = {

			};
			openSearchClientPanel('setSearchClientInfo', 'wide', $M.toGetParam(param));
		}

		// 파입업로드(드래그앤드랍)
		function fnFileDragAndDrop() {
			var param = {
			   'upload_type': $M.getValue('upload_type'),
			   'pixel_limit_yn': $M.getValue('pixel_limit_yn'),
			   'max_size': $M.getValue('max_size'),
			   'size_limit_yn': $M.getValue('size_limit_yn'),
			   'file_type': $M.getValue('file_type'),
			   'file_seq': $M.getValue('file_seq'),
			   'file_ext_type': $M.getValue('file_ext_type'),
                'img_resize' : $M.getValue('img_resize'),
                'pixel_resize_yn': $M.getValue('pixel_resize_yn'),
                'max_width': $M.getValue('max_width'),
                'max_height': $M.getValue('max_height'),
			};

			openFileUploadPanel('setSaveFileInfo', $M.toGetParam(param));
		}

       // 파입업로드(드래그앤드랍 - 멀티)
       function fnFileDragAndDropMulti() {
           var param = {
               'upload_type': $M.getValue('upload_type_multi'),
               // 'pixel_limit_yn': $M.getValue('pixel_limit_yn_multi'),
               'max_size': $M.getValue('max_size_multi'),
               'total_max_count': $M.getValue('total_max_count_multi'),
               // 'size_limit_yn': $M.getValue('size_limit_yn_multi'),
               'file_type': $M.getValue('file_type_multi'),
               'file_seq_str': $M.getValue('file_seq_multi'),
               'file_ext_type': $M.getValue('file_ext_type_multi'),
               'img_resize' : $M.getValue('img_resize_multi'),
               'max_width': $M.getValue('max_width_multi'),
               'max_height': $M.getValue('max_height_multi'),
               'pixel_resize_yn': $M.getValue('pixel_resize_yn_multi')
           };

           openFileUploadMultiPanel('setSaveFileInfoMulti', $M.toGetParam(param));
       }

       // 파입업로드(드래그앤드랍 - 그룹멀티)
       function fnFileDragAndDropGroupMulti() {
           var jsonData = {
               'upload_type' : $M.getValue('upload_type_group_multi'),
               'file_type': $M.getValue('file_type_group_multi'),
               'file_list' : [
                       {
                           "type_id" : $M.getValue("type_id_group_multi_1")
                           , "type_name" : $M.getValue("type_name_group_multi_1")
                           , 'max_count' : $M.getValue("type_max_count_group_multi_1")
                           , 'file_seq_str' : $M.getValue("type_file_seq_group_multi_1")
                       },
                       {
                           "type_id" : $M.getValue("type_id_group_multi_2")
                           , "type_name" : $M.getValue("type_name_group_multi_2")
                           , 'max_count' : $M.getValue("type_max_count_group_multi_2")
                           , 'file_seq_str' : $M.getValue("type_file_seq_group_multi_2")
                       },
                       {
                           "type_id" : $M.getValue("type_id_group_multi_3")
                           , "type_name" : $M.getValue("type_name_group_multi_3")
                           , 'max_count' : $M.getValue("type_max_count_group_multi_3")
                           , 'file_seq_str' : $M.getValue("type_file_seq_group_multi_3")
                       },
                    ]
           }

           var param = {
               'upload_type': $M.getValue('upload_type_group_multi'),
               'max_size': $M.getValue('max_size_group_multi'),
               // 'total_max_count': $M.getValue('total_max_count_group_multi'),
               'file_type': $M.getValue('file_type_group_multi'),
               // 'file_seq_str': $M.getValue('file_seq_group_multi'),
               'file_ext_type': $M.getValue('file_ext_type_group_multi'),
               'img_resize' : $M.getValue('img_resize_group_multi')
               // 'file_json_data' : jsonData
           };

           console.log("$M.toGetParam(param) : ", $M.toGetParam(param))
           console.log("$M.toGetParam(param) : ", param);

           // openFileUploadGroupMultiPanel('setSaveFileInfoGroupMulti', $M.toGetParam(param));
           openFileUploadGroupMultiPanel('setSaveFileInfoGroupMulti', $M.toGetParam(param), jsonData);
       }

       // 파입업로드(드래그앤드랍 - 그룹멀티)
       function setSaveFileInfoGroupMulti(result) {
           alert(JSON.stringify(result));
       }

       function fnFileAllDownload() {
           var fileSeqArr = [];
           $("[name=file_seq_val]").each(function() {
              fileSeqArr.push($(this).val());
           });

           var paramObj = {
               'file_seq_str' : $M.getArrStr(fileSeqArr)
           }

           fileDownloadZip(paramObj);
       }

       function setSaveFileInfo(result) {
          alert(JSON.stringify(result));
       }

       function setSaveFileInfoMulti(result) {
           alert(JSON.stringify(result));

           $(".fileDownloadDiv").remove(); // 파일다운로드 영역 초기화
           $("input[name=file_seq_val]").val('');

           var fileList = result.fileList;
           console.log("fileList : ", fileList);

           // 샘플페이지 파일 6개로 고정.
           for (var i = 0; i < fileList.length; i++) {
               if (i <= 5) {
                   var fileSeq = fileList[i].file_seq;
                   var fileName = fileList[i].file_name;
                   var fileExt = fileList[i].file_ext;
                   var fileSize = fileList[i].file_size;

                   var str = '';
                   str += '<a class="fileDownloadDiv" href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>';
                   str += '<input type="hidden" name="file_seq_val" value="'+fileSeq+'">';
                   $('#fileDownload'+i).append(str);
               }
           }
       }

		// 부품발주번호 프로시저호출
		function fnSendPartOrderSpc() {
		      if($M.getValue('part_order_no') == '') {
		         alert('부품발주번호 입력 요망');
		         return;
		      }
		      var param ={
		            part_order_no : $M.getValue('part_order_no')
		      };

		      $M.goNextPageAjax('/smpl/smpl0101/callProc', $M.toGetParam(param), { method : "POST"},
		         function(result) {
		            if(result.success) {
		               alert(JSON.stringify(result));
		            };
		         }
		      );
		};

		function fileUpload(conf) {

				var frm = document.main_form;
				if (conf == "Y"){
					if (confirm("파일을 등록하시겠습니까?") == true){    //확인

						$M.goNextPageAjax('/file/fileUpload', frm, {method : 'post'},
							function(result) {
					    		if(result.success) {
					    			alert(JSON.stringify(result));

						    			$.each(result.uploadList, function(index, file) {
											$("#"+ file.fieldName +  "_desc").text("javascript:fileDownload(" + file.fileSeq + ");" );
											$("#"+ file.fieldName + "_fileName").text(file.fileName);
											$("#"+ file.fieldName + "_download").attr("onclick","javascript:fileDownload(" + file.fileSeq  + ");  return false; ");
										});

								}else{

					    		}
							}
						);
					}else{   //취소
					    return;
					}
				}
				else {

					$M.goNextPageAjax('/file/fileUpload', frm, {method : 'post'},
						function(result) {
				    		if(result.success) {
				    			alert(JSON.stringify(result));
					    			$.each(result.uploadList, function(index, file) {
										$("#"+ file.fieldName +  "_desc").text("javascript:fileDownload(" + file.fileSeq + ");" );
										$("#"+ file.fieldName + "_fileName").text(file.fileName);
										$("#"+ file.fieldName + "_download").attr("onclick","javascript:fileDownload(" + file.fileSeq  + ");  return false; ");
									});

							}else{

				    		}
						}
					);
				}
			}

		// 장비 부가정보 조회
		function goModelInfoForCommon() {
			var param = {
					s_machine_name : $M.getValue("machine_name")
			};
			openSearchModelPanel('setModelInfoForCommon', 'N', $M.toGetParam(param));
		}

		// 장비 부가정보 조회
		function setModelInfoForCommon(row) {
			$M.setValue("machine_name", row.machine_name);
			$M.goNextPageAjax("/machine/supplement/"+row.machine_name, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			//console.log(result);
		    			 alert(JSON.stringify(result));
		    			 console.log(result);
					}
				}
			);
		}

		// 직원조회(조직도) 조회
		function setMemberOrgMapPanel(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 기본 조직도 조회
		function setOrgMapPanel(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 조직도(센터) 조회
		function setOrgMapCenterPanel(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 조직도(대리점) 조회
		function setOrgMapAgencyPanel(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 조직도(메인) 조회
		function setOrgMapMainPanel(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 계정 조회
		function setAccountInfoPanel(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 차량 조회
		function setCarInfo(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		// 예금 조회
		function setDepositInfoPanel(result) {
			alert(JSON.stringify(result));
			console.log(JSON.stringify(result));
		}

		function fnMyExecFuncName(data) {
			alert(JSON.stringify(data));
		}

		// 견적서 팝업 조회
		function goSearchRfqPenel() {
			var param = {
				rfq_type : 'MACHINE',
				type_select_yn : "N",
				refer_yn : "Y"
			};
			openRfqReferPanel('fnSetRfq', $M.toGetParam(param));
		}

		// 견적서 세팅
		function fnSetRfq(data) {
			alert(JSON.stringify(data));
		}

		// 개인정보동의 팝업
		function goSearchPrivacyAgree() {
			var param = {
				cust_no : $M.getValue("cust_no2")
			}
			$M.goNextPageAjax("/comp/comp0306/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						var custInfo = result.custInfo;
						if (custInfo.personal_yn != "Y") {
							if (confirm("개인정보 동의사항을 확인하세요") == true) {
								openPrivacyAgreePanel('fnSetPrivacy', $M.toGetParam(param));
							}
						}
					}
				}
			);
		}

		// 개인정보 동의 세팅
		function fnSetPrivacy(data) {
			alert(JSON.stringify(data));
		}

		  // 배송정보 팝업
	    function goDeliveryInfo() {
	    	var params = {
	    			cust_no : $M.getValue("delivery_cust_no"),
	    			invoice_type_cd : $M.getValue("invoice_type_cd")
	    	};

	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }

	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	alert(JSON.stringify(data));
	    }

	    function fnSetDeviceHis(data) {
	    	alert(JSON.stringify(data));
	    }

	    // 연관업무 setValue
      function fnInit() {
    	$M.setValue("__s_cust_no", "20130603145119670");
    	$M.setValue("__s_cust_name", "장현석");
    	$M.setValue("__s_hp_no", "01066003545");

    	$M.setValue("__s_body_no", "4CR2-20627");
    	$M.setValue("__s_machine_seq", "42973");
    	$M.setValue("__s_machine_doc_no", "2020-0106-01");
      }

	  function goARS() {
		  var param = {
					cust_no : $M.getValue('ars_cust_no')
				}
				var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=375, height=340, left=0, top=0";
	            $M.goNextPage('/comp/comp0703', $M.toGetParam(param), {popupStatus : poppupOption});
	  }

	  // 매출처리
	  function goInoutProc() {
		  var param = {
			  "part_sale_no" : $M.getValue("part_sale_no"),
			  "job_report_no" : $M.getValue("job_report_no"),
			  "rental_doc_no" : $M.getValue("rental_doc_no"),
			  "machine_used_no" : $M.getValue("machine_used_no")
		  }

		  openInoutProcPanel("fnSetInout", $M.toGetParam(param));
	  }

	  function fnSetInout(data) {
		  alert(JSON.stringify(data));
	  }

	  // 거래원장상세팝업
	  function goDealLedger() {
		  var param = {
			  "s_cust_no"  			: $M.getValue("s_cust_no_c1"),
			  "s_inout_doc_type_cd" : $M.getValue("s_inout_doc_type_cd_c1"),
			  "s_body_no" 			: $M.getValue("s_body_no_c1"),
			  "s_start_dt" 			: $M.getValue("s_start_dt_c1"),
			  "s_end_dt" 				: $M.getValue("s_end_dt_c1"),
		  }

		  openDealLedgerPanel($M.toGetParam(param));

	  }

	  // 고객장비거래원장상세팝업
	  function goCustMachineDealLedger() {
		  var param = {
			  "s_cust_no"  	: $M.getValue("s_cust_no_c2"),
			  "s_amt"  		: $M.getValue("s_amt_c2"),
		  }

		  openCustMachineDealLedgerPanel($M.toGetParam(param));

	  }
	  // 고객조회 팝업
	  function goCustInfo() {

		  var param = {
			  "s_cust_yn"  	: $M.getValue("s_cust_yn"),
		  }

		  openSearchCustPanel('setCustInfo', $M.toGetParam(param));

	  }

	  // 차주명조회 팝업
	  function goMachineCust() {

		  var param = {
			  "s_cust_name"  	: $M.getValue("s_cust_name_m"),
		  }

		  openMachineCustPanel('setMachineCustPanel', $M.toGetParam(param));

	  }

	  // 차주명조회 데이터 콜백
	  function setMachineCustPanel(data) {
		  alert(JSON.stringify(data));
	  }

	  // 보유기종 팝업
	  function goHaveMachineCust() {

		  var param = {
			  "cust_no"  	: $M.getValue("cust_no_have"),
		  }

		  openHaveMachineCustPanel($M.toGetParam(param));
	  }

      // 그룹코드 팝업 openGroupCodeDetailPanel
	  function goGroupCodeCust() {

          var param = {
              group_code : $M.getValue("group_code_detail"),
              all_yn : $M.getValue("group_code_detail_use"),
              show_extra_cols : $M.getValue("group_code_detail_show_extra_cols"),
              requireds : $M.getValue("group_code_detail_requireds"),
          }
		  openGroupCodeDetailPanel($M.toGetParam(param));
	  }

      // 업무DB 분류 선택 팝업
	  function goWorkDbGrup() {
          var param = {
          };
          openWorkDbGroup("setSearchWorkDbDir",$M.toGetParam(param));
	  }

   </script>
</head>
<body>
<form id="main_form" name="main_form" enctype="multipart/form-data"  >
<!-- contents 전체 영역 -->
   <div class="content-wrap">
      <div class="content-box">
   <!-- 메인 타이틀 -->
         <div class="main-title">
         </div>
   <!-- /메인 타이틀 -->
         <div class="contents" style="width:100%; float: left;">
   <!-- 기본 -->
               <table class="table-border">

          		 <h2>파라미터 조회 팝업</h2>
   		 			<colgroup>
						<col width="170px">
						<col width="220px">
						<col width="220px">
						<col width="120px">
						<col width="120px">
						<col width="150px">
						<col width="150px">
						<col width="140px">
						<col width="140px">
						<col width="220px">
					</colgroup>
               		<thead>
               		<th>기능명</th>
               		<th>함수명</th>
               		<th>param1</th>
               		<th>param2</th>
               		<th>param3</th>
               		<th>param4</th>
               		<th>param5</th>
               		<th>param6</th>
               		<th>기능버튼</th>
               		<th>예시</th>
               		</thead>
                  	<tbody>
                  	 <tr>
                        <td><label>ARS 결제 팝업</label></td>
                        <td><label>openSearchArsRequest</label></td>
                        <td><input type="text" class="form-control" id="ars_cust_no" name="ars_cust_no" value="20151211131622293" style="width: 90px;" placeholder="고객번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goARS();">ARS결제</button></td>
                    	<td><span style="color:red;">cust_no</span><span>=20060727140532063</span></td>
                     </tr>
                     <tr>
                        <td><label>사업자명세조회</label></td>
                        <td><label>openSearchBregSpecPanel</label></td>
                        <td><input type="text" class="form-control" id="cust_no" name="cust_no" value="" style="width: 90px;" placeholder="고객번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnSearchBregSpec();">사업자명세조회</button></td>
                    	<td><span style="color:red;">cust_no</span><span>=20130603145119670</span></td>
                     </tr>
                     <tr>
                        <td><label>사업자정보조회</label></td>
                        <td><label>openSearchBregInfoPanel</label></td>
                        <td><input type="text" class="form-control" id="breg_name" name="breg_name" style="width: 90px;" value="" placeholder="업체명"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnSearchBregInfo();">사업자정보조회</button></td>
                    	<td><p>s_breg_name=상사</p></td>
                     </tr>
                     <tr>
                        <td><label>부품조회</label></td>
                        <td><label>openSearchPartPanel</label></td>
                        <td>
                        	<input type="text" class="form-control" id="part_no" name="part_no" style="width: 90px;"   value="" placeholder="부품번호">
                        </td>
                        <td>
                        	<select class="form-control" id="s_part_mng_cd" name="s_part_mng_cd">
								<option value="">- 부품관리구분 - </option>
								<c:forEach var="item" items="${codeMap['PART_MNG']}">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
                        </td>
                         <td>
                    		<select class="form-control" id="warehouse_cd" name="warehouse_cd">
								<option value="">- 창고구분 - </option>
								<c:forEach var="item" items="${codeMap['WAREHOUSE']}">
									<option value="${item.code_value}">${item.code_name}</option>
								</c:forEach>
							</select>
                        </td>
                        <td>
                        	 창고부품만 조회<br>(창고번호 입력한경우)
                       		 <input type="text" class="form-control" id="only_warehouse_yn" name="only_warehouse_yn" style="width: 130px;" value="" placeholder="창고부품만 조회( Y / N )">
                        </td>

                        <td><input type="text" class="form-control" id="part_cust_no" name="part_cust_no" placeholder="고객번호"></td>
                        <td></td>
                        <td><button type="button" class="btn btn-info" onclick="javascript:fnSearchPart();">부품조회(단일)</button><button type="button" class="btn btn-info" onclick="javascript:fnSearchPartMulti();">부품조회(다중)</button></td>
                    	<td><span style="color:red;">multi_yn</span>='Y 또는 N'&s_part_mng_cd=20&s_part_no=4033-32011-0&s_only_warehouse_yn='Y 또는 N'&s_warehouse_cd=6000&s_cust_no='20071217225716887'</span></td>
                     </tr>
                     <tr>
                        <td><label>이메일보내기</label></td>
                        <td><label>openSendEmailPanel</label></td>
                        <td><input type="text" class="form-control" placeholder="받는 사람 이메일" id="user_email" name="user_email" maxlength="80" style="width: 90px;" value="to=aaa@gmail.com;bbb@naver.com"></td>
                        <td><input type="text" class="form-control" placeholder="메일 제목" id="email_title" name="email_title" maxlength="80" style="width: 90px;"></td>
                        <td><textarea class="form-control" style="height: 100px;" id="email_body" name="email_body"></textarea></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-default" onclick="javascript:fnSendMail();">이메일</button></td>
                    	<td>
                    		<span>to=aaa@gmail.com<span style="color:blue;">;</span>bbb@naver.com&subject=메일제목&body=메일내용</span>
                    		<br>받은 사람 메일 주소(구분자 ';')
                    	</td>

                     </tr>
                     <tr>
                        <td><label>결재처리</label></td>
                        <td><label>openApprPanel</label></td>
                        <td><input type="text" class="form-control" id="mem_appr_seq" name="mem_appr_seq" style="width: 90px;" value="" placeholder="결재번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-default" onclick="javascript:fnApproval();">결재처리</button></td>
                    	<td><span style="color:red;">mem_appr_seq</span><span>=56844</span></td>
                     </tr>
                     <tr>
                        <td><label>발주요청조회</label></td>
                        <td><label>openOrderRequestPartPanel</label></td>
                        <td><input type="text" class="form-control" id="s_req_part_cust_no" name="s_req_part_cust_no" style="width: 90px;" value="" placeholder="고객번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnOrderRequestPart();">발주요청조회</button></td>
                    	<td><span style="color:red;">cust_no</span><span>=20190114095213181</span></td>
                     </tr>
                     <tr>
                        <td><label>부품발주요청</label></td>
                        <td><label>openOrderPartPanel</label></td>
                        <td><input type="text" class="form-control" id="p_part_no" name="p_part_no" style="width: 90px;" value="" placeholder="부품번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnOrderPart();">부품발주요청</button></td>
                    	<td><span>s_part_no=ZZ90239</span></td>
                     </tr>
                     <tr>
                        <td><label>매입처조회</label></td>
                        <td><label>openSearchClientPanel</label></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnSearchClientComm();">매입처조회</button>
                    	<button type="button" class="btn btn-info" onclick="javascript:fnSearchClientWide();">매입처조회(와이드)</button></td>
                    	<td><span style="color:red;">field_type</span><span>='comm 또는 wide'</span></td>
                     </tr>
                     <tr>
                        <td><label>견본문자</label></td>
                        <td><label>openSearchSampleSMSPanel</label></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnSearchSampleCommSMS();">공통견본문자</button>
                    	<button type="button" class="btn btn-info" onclick="javascript:fnSearchSampleIndiSMS();">개별견본문자</button></td>
                    	<td><span style="color:red;">tap_type</span><span>='comm 또는 indi'</span></td>
                     </tr>
                     <tr>
                        <td><label>입출고내역</label></td>
                        <td><label>openInoutPartPanel</label></td>
                        <td><input type="text" class="form-control" id="in_part_no" name="in_part_no" style="width: 90px;" value="" placeholder="부품번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnInoutPartInfo();">입출고내역</button></td>
                    	<td><span>tap 사용 시에만 part_no=ZZ90239</span></td>
                     </tr>
                     <tr>
                        <td><label>부품이동요청</label></td>
                        <td><label>openTransPartPanel</label></td>
                        <td><input type="text" class="form-control" id="trans_part_no" name="trans_part_no" style="width: 90px;" value="" placeholder="부품번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goTransPart();">부품이동요청</button></td>
                    	<td><span style="color:red;">part_no</span><span>=M739480</span></td>
                     </tr>
                     <tr>
                        <td><label>직원조회</label></td>
                        <td><label>openSearchMemberPanel</label></td>
                        <td><input type="text" class="form-control" id="s_org_code" name="s_org_code" style="width: 90px;" value="" placeholder="부서코드"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goMemberInfo();">직원조회</button></td>
                    	<td><span>org_code=4000</span></td>
                     </tr>
                     <tr>
                        <td><label>모델조회</label></td>
                        <td><label>openSearchModelPanel</label></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td><button type="button" class="btn btn-info" onclick="javascript:goModelInfo();">모델조회(단일)</button><button type="button" class="btn btn-info" onclick="javascript:goModelInfoMulti();">모델조회(다중)</button></td>
                    	<td><span style="color:red;">multi_yn</span><span>='Y 또는 N'</span></td>
                     </tr>
                     <tr>
                        <td><label>개인정보동의조회</label></td>
                        <td><label>openPrivacyAgreePanel</label></td>
                        <td><input type="text" class="form-control" id="cust_no2" name="cust_no2" value="" style="width: 90px;" placeholder="고객번호"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td><button type="button" class="btn btn-info" onclick="javascript:goSearchPrivacyAgree();">개인정보동의</button></td>
                    	<td><span style="color:red;">cust_no</span><span>=20200205172844444</span></td>
                     </tr>
                     <tr>
                        <td><label>배송정보</label></td>
                        <td><label>openDeliveryInfoPanel</label></td>
                        <td><input type="text" class="form-control" id="delivery_cust_no" name="delivery_cust_no" value="" style="width: 90px;" placeholder="고객번호"></td>
                        <td><input type="text" class="form-control" id="invoice_type_cd" name="invoice_type_cd" value="" style="width: 90px;" placeholder="송장타입코드"></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td><button type="button" class="btn btn-info" onclick="javascript:goDeliveryInfo();">배송정보</button></td>
                    	<td><span style="color:red;">cust_no</span>=20071217225716887&<span style="color:red;">invoice_type_cd</span>=05</td>
                     </tr>
                     <%-- 유무상부품관리, 추가품목선별 : 계약/출하, 장비견적서에서만 사용. 개발참고에서 테스트 불가. (부모페이지의 데이터가 필요하기 때문) --%>
<!--                      <tr> -->
<!--                         <td><label>유무상부품관리</label></td> -->
<!--                         <td><label>openFreeAndPaidMachinePart</label></td> -->
<!--                         <td> -->
<!--                         	<input type="text" class="form-control" id="machine_name" name="machine_name" style="width: 90px;" value="" placeholder="장비명"> -->
<!--                         </td> -->
<!--                         <td> -->
<!--                 	        <select name="page_type" id="page_type" class="form-control"> -->
<!--                      			<option value="">- 페이지타입 -</option> -->
<!--                      			<option value="DOC">장비계약출하(DOC)</option> -->
<!--                      			<option value="RFQ">견적서(RFQ)</option> -->
<!--                      		</select>  -->
<!--                         </td> -->
<!--                         <td></td> -->
<!--                         <td></td> -->
<!--                         <td></td> -->
<!--                         <td><button type="button" class="btn btn-info" onclick="javascript:goFreeAndPaidMachinePart();">유무상부품조회</button></td> -->
<!--                     	<td><span style="color:red;">machine_name</span><span>=VIO35-6A-J</span>&<span style="color:red;">page_type</span><span>=doc</span></td> -->
<!--                      </tr> -->
<!--                      <tr> -->
<!--                         <td><label>추가품목선별</label></td> -->
<!--                         <td><label>openAddMachinePartItem</label></td> -->
<!--                         <td> -->
<!--                         	<input type="text" class="form-control" id="machine_name" name="machine_name" style="width: 90px;" value="" placeholder="장비명"> -->
<!--                         </td> -->
<!--                         <td></td> -->
<!--                         <td></td> -->
<!--                         <td></td> -->
<!--                         <td></td> -->
<!--                         <td><button type="button" class="btn btn-info" onclick="javascript:goAddMachinePartItem();">추가품목선별</button></td> -->
<!--                     	<td><span style="color:red;">machine_name</span><span>=VIO35-6A-J</span></td> -->
<!--                      </tr> -->
                     <tr>
                     	<td><label>파일업로드</label></td>
                     	<td><label>openFileUploadPanel</label></td>
                     	<td>
                     		<select name="upload_type" id="upload_type" class="form-control">
                     			<option value="">- 업로드타입 -</option>
                     			<option value="MMS">MMS파일(MMS)</option>
                     			<option value="MEM">직원(MEM)</option>
                     			<option value="LOGIN">로그인이미지(LOGIN)</option>
                     			<option value="BBS">전산Q&A(BBS)</option>
                     			<option value="NOTICE">공지사항(NOTICE)</option>
                     			<option value="MACHINE">장비관련(MACHINE)</option>
                     			<option value="PART">부품관련(PART)</option>
                     			<option value="SERVICE">서비스관련(SERVICE)</option>
                     			<option value="HELP">도움말관련(HELP)</option>
                     			<option value="WORKDB">업무DB(WORKDB)</option>
                                <option value="CMAIN">메인이미지(CMAIN)</option>
                     		</select>
                     		<select name="file_type" id="file_type" class="form-control">
                     			<option value="">- 파일타입 -</option>
                     			<option value="img">이미지(img)</option>
                     			<option value="etc">일반파일(etc)</option>
                     			<option value="both">이미지+일반(both)</option>
                     		</select>
                     	</td>

						<td>
<%--							<input type="text" class="form-control" id="pixel_limit_yn" name="pixel_limit_yn" style="width: 90px;" value="" placeholder="해상도제한여부(N)" >--%>
                            리사이징<input type="text" class="form-control" id="img_resize" name="img_resize"   style="width: 90px;" value="" placeholder="리사이징(1024)">
                            가로/세로 리사이징
                            <input type="text" class="form-control" id="pixel_resize_yn" name="pixel_resize_yn"  style="width: 90px;" value="" placeholder="리사이징여부(Y/N)">
							<input type="text" class="form-control" id="max_width" name="max_width"  style="width: 90px;" value="" placeholder="가로(1024)" >
							<input type="text" class="form-control" id="max_height" name="max_height"   style="width: 90px;" value="" placeholder="세로(768)" >
						</td>
						<td>무조건 제한
							<input type="text" class="form-control" id="max_size" name="max_size" style="width: 90px;" value="" placeholder="제한용량(KB)" >
						</td>
						<td>
							파일순번<br/>
							(기존파일조회용)<br/>
							기존파일조회시 - 유형체크안함<br/>
							<input type="text" class="form-control" id="file_seq" name="file_seq" style="width: 90px;" datatype="int" value="" placeholder="파일순번" >
						</td>
							<td>특정확장자만 올리는경우
							<input type="text" class="form-control" id="file_ext_type" name="file_ext_type" style="width: 90px;" value="" placeholder="파일확장자입력" >
						</td>

						<td>
							<input type="text" class="form-control" id="file_open_src" name="file_open_src"  maxLength="200" style="width: 90px;" value="" placeholder="file_seq or 웹주소" >
							<button type="button" class="btn btn-info"  onclick="javascript:$M.goNextPageLayerImage($M.getValue('file_open_src'));">파일보기팝업</button>
						</td>
						<td><button type="button" class="btn btn-info"  onclick="javascript:fnFileDragAndDrop();">파일업로드</button></td>
						<td><span style="color:red;">upload_type</span>=MMS&<span style="color:red;">file_type</span>=img&max_width=&max_height=&pixel_limit_yn=N&max_size=&size_limit_yn=Y&file_ext_type=&img_resize=&pixel_resize_yn=</td>
                     </tr>
                     <tr>
                         <td><label>파일업로드(다중)</label></td>
                         <td><label>openFileUploadMultiPanel</label></td>
                         <td>
                             <select name="upload_type_multi" id="upload_type_multi" class="form-control">
                                 <option value="">- 업로드타입 -</option>
                                 <option value="MMS">MMS파일(MMS)</option>
                                 <option value="MEM">직원(MEM)</option>
                                 <option value="LOGIN">로그인이미지(LOGIN)</option>
                                 <option value="BBS">전산Q&A(BBS)</option>
                                 <option value="NOTICE">공지사항(NOTICE)</option>
                                 <option value="MACHINE">장비관련(MACHINE)</option>
                                 <option value="PART">부품관련(PART)</option>
                                 <option value="SERVICE">서비스관련(SERVICE)</option>
                                 <option value="HELP">도움말관련(HELP)</option>
                                 <option value="WORKDB">업무DB(WORKDB)</option>
                                 <option value="CMAIN">메인이미지(CMAIN)</option>
                             </select>
                             <select name="file_type_multi" id="file_type_multi" class="form-control">
                                 <option value="">- 파일타입 -</option>
                                 <option value="img">이미지(img)</option>
                                 <option value="etc">일반파일(etc)</option>
                                 <option value="both">이미지+일반(both)</option>
                             </select>
                         </td>

                         <td>
<%--                             <input type="text" class="form-control" id="max_width_multi" name="max_width_multi"  style="width: 90px;" value="" placeholder="가로(1024)" >--%>
<%--                             <input type="text" class="form-control" id="max_height_multi" name="max_height_multi"   style="width: 90px;" value="" placeholder="세로(768)" >--%>
                             리사이징<input type="text" class="form-control" id="img_resize_multi" name="img_resize_multi"   style="width: 90px;" value="" placeholder="리사이징(1024)">
<%--                             <input type="text" class="form-control" id="pixel_limit_yn_multi" name="pixel_limit_yn_multi" style="width: 90px;" value="" placeholder="해상도제한여부(N)" >--%>
                            가로/세로 리사이징
                            <input type="text" class="form-control" id="pixel_resize_yn_multi" name="pixel_resize_yn_multi"  style="width: 90px;" value="" placeholder="리사이징여부(Y/N)">
                            <input type="text" class="form-control" id="max_width_multi" name="max_width_multi"  style="width: 90px;" value="" placeholder="가로(1024)" >
                            <input type="text" class="form-control" id="max_height_multi" name="max_height_multi"   style="width: 90px;" value="" placeholder="세로(768)" >
                         </td>
                         <td>
                             총 용량 제한 <input type="text" class="form-control" id="max_size_multi" name="max_size_multi" style="width: 90px;" value="" placeholder="제한용량(KB)" >
                             총 개수 제한<br/>(0 : 무제한) <input type="text" class="form-control" id="total_max_count_multi" name="total_max_count_multi" style="width: 90px;" value="" placeholder="총 파일 개수" >
                         </td>
                         <td>
                             파일순번<br/>
                             (기존파일조회용)<br/>
                             (#으로묶음)<br/>
<%--                             <input type="text" class="form-control" id="file_seq_multi" name="file_seq_multi" style="width: 120px;" value="" placeholder="파일순번 (1#2#3)" >--%>
                             <textarea class="form-control" style="height: 50px;" id="file_seq_multi" name="file_seq_multi" placeholder="파일순번 (1#2#3)"></textarea>
                         </td>
                         <td>특정확장자만 올리는경우
                             <input type="text" class="form-control" id="file_ext_type_multi" name="file_ext_type_multi" style="width: 90px;" value="" placeholder="파일확장자입력" >
                         </td>

                         <td>
<%--                             <input type="text" class="form-control" id="file_open_src_multi" name="file_open_src_multi"  maxLength="200" style="width: 90px;" value="" placeholder="file_seq or 웹주소" >--%>
<%--                             <button type="button" class="btn btn-info"  onclick="javascript:$M.goNextPageLayerImage($M.getValue('file_open_src_multi'));">파일보기팝업</button>--%>
                         </td>
                         <td><button type="button" class="btn btn-info"  onclick="javascript:fnFileDragAndDropMulti();">파일업로드(다중)</button></td>
                         <td><span style="color:red;">upload_type</span>=MMS&<span style="color:red;">file_type</span>=img&max_width=&max_height=&max_size=&total_max_count=&file_ext_type=&img_resize=&pixel_resize_yn=</td>
                     </tr>
                     <tr>
                         <td><label>파일일괄다운로드</label></td>
                         <td><label>fnFileAllDownload</label></td>
                         <td id="fileDownload0">

                         </td>
                         <td id="fileDownload1">

                         </td>
                         <td id="fileDownload2">

                         </td>
                         <td id="fileDownload3">

                         </td>
                         <td id="fileDownload4">

                         </td>
                         <td id="fileDownload5">
                         </td>
                         <td><button type="button" class="btn btn-info"  onclick="javascript:fnFileAllDownload();">파일일괄다운로드</button></td>
                         <td><span style="color:red;"></span><span style="color:red;"></span></td>
                     </tr>
                     <tr>
                         <td><label>파일업로드(그룹다중)</label></td>
                         <td><label>openFileUploadGroupMultiPanel</label></td>
                         <td>
                             <select name="upload_type_group_multi" id="upload_type_group_multi" class="form-control">
                                 <option value="">- 업로드타입 -</option>
                                 <option value="MMS">MMS파일(MMS)</option>
                                 <option value="MEM">직원(MEM)</option>
                                 <option value="LOGIN">로그인이미지(LOGIN)</option>
                                 <option value="BBS">전산Q&A(BBS)</option>
                                 <option value="NOTICE">공지사항(NOTICE)</option>
                                 <option value="MACHINE">장비관련(MACHINE)</option>
                                 <option value="PART">부품관련(PART)</option>
                                 <option value="SERVICE">서비스관련(SERVICE)</option>
                                 <option value="HELP">도움말관련(HELP)</option>
                                 <option value="WORKDB">업무DB(WORKDB)</option>
                             </select>
                             <select name="file_type_group_multi" id="file_type_group_multi" class="form-control">
                                 <option value="">- 파일타입 -</option>
                                 <option value="img">이미지(img)</option>
                                 <option value="etc">일반파일(etc)</option>
                                 <option value="both">이미지+일반(both)</option>
                             </select>
                         </td>

                         <td>
                             리사이징<input type="text" class="form-control" id="img_resize_group_multi" name="img_resize_group_multi"   style="width: 90px;" value="" placeholder="리사이징(1024)">
                         </td>
                         <td>
                             총 용량 제한 <input type="text" class="form-control" id="max_size_group_multi" name="max_size_group_multi" style="width: 90px;" value="" placeholder="제한용량(KB)" >
                         </td>
                         <td>
                             항목별 정보 세팅<br/><br/>
                             항목 ID명 <input type="text" class="form-control" id="type_id_group_multi_1" name="type_id_group_multi_1" style="width: 90px;" value="" placeholder="machine_file" >
                             항목명 (이름) <input type="text" class="form-control" id="type_name_group_multi_1" name="type_name_group_multi_1" style="width: 90px;" value="" placeholder="장비계약서" >
                             파일개수제한 <input type="text" class="form-control" id="type_max_count_group_multi_1" name="type_max_count_group_multi_1" style="width: 120px;" value="" placeholder="항목 파일 개수(기본:1)">
                             파일정보(#)<textarea class="form-control" style="height: 40px; width: 100px;" id="type_file_seq_group_multi_1" name="type_file_seq_group_multi_1" placeholder="파일순번 (1#2#3)"></textarea>
                         </td>
                         <td>
                             항목별 정보 세팅<br/><br/>
                             항목 ID명 <input type="text" class="form-control" id="type_id_group_multi_2" name="type_id_group_multi_2" style="width: 90px;" value="" placeholder="cap_file" >
                             항목명 (이름) <input type="text" class="form-control" id="type_name_group_multi_2" name="type_name_group_multi_2" style="width: 90px;" value="" placeholder="CAP계약서" >
                             파일개수제한 <input type="text" class="form-control" id="type_max_count_group_multi_2" name="type_max_count_group_multi_2" style="width: 120px;" value="" placeholder="항목 파일 개수(기본:1)">
                             파일정보(#)<textarea class="form-control" style="height: 40px; width: 100px;" id="type_file_seq_group_multi_2" name="type_file_seq_group_multi_2" placeholder="파일순번 (1#2#3)"></textarea>
                         </td>
                         <td>
                             항목별 정보 세팅<br/><br/>
                             항목 ID명 <input type="text" class="form-control" id="type_id_group_multi_3" name="type_id_group_multi_3" style="width: 90px;" value="" placeholder="sar_file" >
                             항목명 (이름) <input type="text" class="form-control" id="type_name_group_multi_3" name="type_name_group_multi_3" style="width: 90px;" value="" placeholder="SA-R계약서" >
                             파일개수제한 <input type="text" class="form-control" id="type_max_count_group_multi_3" name="type_max_count_group_multi_3" style="width: 120px;" value="" placeholder="항목 파일 개수(기본:1)">
                             파일정보(#)<textarea class="form-control" style="height: 40px; width: 100px;" id="type_file_seq_group_multi_3" name="type_file_seq_group_multi_3" placeholder="파일순번 (1#2#3)"></textarea>
                         </td>
                         <td><button type="button" class="btn btn-info"  onclick="javascript:fnFileDragAndDropGroupMulti();">파일업로드(그룹다중)</button></td>
                         <td><span style="color:red;">upload_type</span>=MMS&<span style="color:red;">file_type</span>=img&max_width=&max_height=&max_size=&total_max_count=&file_ext_type=&img_resize=&pixel_resize_yn=</td>
                     </tr>
                     <tr>
                        <td><label>거래시필수확인사항</label></td>
                        <td><label>openCheckRequiredPanel</label></td>
                        <td><input type="text" class="form-control" id="s_cr_cust_no" name="s_cr_cust_no" style="width: 90px;" value="" placeholder="고객번호"></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:fnCheckRequired();">거래필수확인</button></td>
                    	<td><span style="color:red;">cust_no</span><span>=2007010100001136</span></td>
                     </tr>
                     <tr>
                        <td><label>문자발송조회</label></td>
                        <td><label>openSearchSendSMSPanel</label></td>
                     	<td><input type="text" class="form-control" id="receiver_name" name="receiver_name" style="width: 90px;" value="" placeholder="수신자명"></td>
                     	<td><input type="text" class="form-control" id="phone_no" name="phone_no" style="width: 90px;" value="" placeholder="수신자번호"></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goSendSmsHis();">문자발송내역조회</button></td>
                    	<td><span style="color:red;">receiver_name&phone_no</span><span>=no data</span></td>
                     </tr>
                     <tr>
                        <td><label>매출처리(팝업)</label></td>
                        <td><label>openInoutProcPanel</label></td>
                     	<td><input type="text" class="form-control" id="part_sale_no" name="part_sale_no" style="width: 90px;" value="" placeholder="수주번호"></td>
                     	<td><input type="text" class="form-control" id="job_report_no" name="job_report_no" style="width: 90px;" value="" placeholder="정비번호"></td>
                     	<td><input type="text" class="form-control" id="rental_doc_no" name="rental_doc_no" style="width: 90px;" value="" placeholder="렌탈번호"></td>
                     	<td><input type="text" class="form-control" id="machine_used_no" name="machine_used_no" style="width: 90px;" value="" placeholder="중고장비번호"></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goInoutProc();">매출처리</button></td>
                    	<td><span style="color:red;">part_sale_no</span><span>=PS2020-C770 또는</span><br><span style="color:red;">job_report_no</span><span>=JR20201021-013 또는 <br><span style="color:red;">rental_doc_no</span><span>=RT20201102-002 또는</span><br><span style="color:red;">machine_used_no</span><span>=MU2020-2033</span></td>
                     </tr>
                     <tr>
                        <td><label>거래원장 상세(팝업)</label></td>
                        <td><label>openDealLedgerPanel</label></td>
                     	<td><input type="text" class="form-control" id="s_cust_no_c1" name="s_cust_no_c1" style="width: 90px;" value="" placeholder="고객번호"></td>
                     	<td>
            				<select class="form-control" id="s_inout_doc_type_cd_c1" name="s_inout_doc_type_cd_c1">
								<option value="">- 전체 -</option>
								<option value="05">수주</option>
								<option value="07">정비</option>
								<option value="11">렌탈</option>
							</select>
						</td>
                     	<td><input type="text" class="form-control" id="s_body_no_c1" name="s_body_no_c1" style="width: 90px;" value="" placeholder="차대번호"></td>
                     	<td><input type="text" class="form-control" id="s_start_dt_c1" name="s_start_dt_c1" style="width: 90px;" value="" dateFormat="" placeholder="시작일"></td>
                     	<td><input type="text" class="form-control" id="s_end_dt_c1" name="s_end_dt_c1" style="width: 90px;" value="" dateFormat="" placeholder="종료일"></td>
                    	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goDealLedger();">거래원장</button></td>
                    	<td><span><span style="color:red;">s_cust_no</span>=20071217225716887&s_inout_doc_type_cd=05&s_body_no=070123B&s_start_dt=20200714&s_end_dt=20201014</span></td>
                     </tr>
                     <tr>
                        <td><label>고객장비거래원장 상세(팝업)</label></td>
                        <td><label>openCustMachineDealLedgerPanel </label></td>
                     	<td><input type="text" class="form-control" id="s_cust_no_c2" name="s_cust_no_c2" style="width: 90px;" value="" placeholder="고객번호"></td>
                     	<td><input type="text" class="form-control" id="s_amt_c2" name="s_amt_c2" style="width: 90px;" value="" placeholder="금액"></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goCustMachineDealLedger();">고객장비거래원장</button></td>
                    	<td><span><span style="color:red;">s_cust_no</span>=20191119161555982&s_amt=1000</span></td>
                     </tr>
                     <tr>
                        <td><label>고객조회</label></td>
                        <td><label>openSearchCustPanel </label></td>
                     	<td><input type="text" class="form-control" id="s_cust_yn" name="s_cust_yn" style="width: 90px;" value="" placeholder="보유기종별 유무"></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goCustInfo();">고객조회</button></td>
                    	<td><span>s_cust_yn=Y</span></td>
                     </tr>
                     <tr>
                        <td><label>차주명조회</label></td>
                        <td><label>openMachineCustPanel </label></td>
                     	<td><input type="text" class="form-control" id="s_cust_name_m" name="s_cust_name_m" style="width: 90px;" value="" placeholder="고객명"></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goMachineCust();">차주명조회</button></td>
                    	<td><span>s_cust_name=배병곤</span></td>
                     </tr>
                     <tr>
                        <td><label>보유기종</label></td>
                        <td><label>openHaveMachineCustPanel </label></td>
                     	<td><input type="text" class="form-control" id="cust_no_have" name="cust_no_have" style="width: 90px;" value="" placeholder="고객번호"></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goHaveMachineCust();">보유기종</button></td>
                    	<td><span><span style="color:red;">cust_no</span>=20071217225716887</span></td>
                     </tr>
                     <tr>
                        <td><label>그룹코드관리</label></td>
                        <td><label>openGroupCodeDetailPanel </label></td>
                     	<td>
                            <input type="text" style="width : 150px";
                                   id="group_code_detail"
                                   name="group_code_detail"
                                   idfield="group_code"
                                   easyui="combogrid"
                                   header="Y"
                                   easyuiname="groupCode"
                                   panelwidth="220"
                                   maxheight="155"
                                   textfield="code_name"
                                   multi="N"
                                   placeholder="그룹코드"/>
<%--                            <input type="text" class="form-control" id="group_code_detail" name="group_code_detail" style="width: 90px;" value="" >--%>
                        </td>
                     	<td><input type="text" class="form-control" id="group_code_detail_use" name="group_code_detail_use" style="width: 90px;" value="" placeholder="전체출력여부"></td>
                     	<td><input type="text" class="form-control" id="group_code_detail_show_extra_cols" name="group_code_detail_show_extra_cols" style="width: 90px;" value="" placeholder="추가필드항목"></td>
                     	<td><input type="text" class="form-control" id="group_code_detail_requireds" name="group_code_detail_requireds" style="width: 90px;" value="" placeholder="항목의 필수값"></td>
                     	<td></td>
                     	<td></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:goGroupCodeCust();">그룹코드관리</button></td>
                    	<td><span><span style="color:red;">group_code</span>=TRIP_IN_OIL&all_yn='Y/N'&show_extra_cols=v1,v2&requireds=v1,v2,v3</span></td>
                     </tr>
<%--                     [15124] 퇴사자 업무 이관 팝업 추가 - 김경빈 --%>
                     <tr>
                         <td><label>퇴사자 업무 이관</label></td>
                         <td><label>openRetireYiguanPanel</label></td>
                         <td>
                             <input type="text" class="form-control" id="retire_mem_no" name="retire_mem_no" style="width : 150px;" value="MB00000341" placeholder="직원번호"/>
                         </td>
                         <td></td>
                         <td></td>
                         <td></td>
                         <td></td>
                         <td></td>
                         <td><button type="button" class="btn btn-info" onclick="javascript:goRetireYiguan();">퇴사자 업무 이관</button></td>
                         <td><span><span style="color:red;">mem_no</span>=MB00000341</span></td>
                     </tr>
<%--                     업무디비 뎁스선택 - 류성진 --%>
                     <tr>
                         <td><label>업무DB 분류선택</label></td>
                         <td><label>openWorkDbGroup</label></td>
                         <td></td>
                         <td></td>
                         <td></td>
                         <td></td>
                         <td></td>
                         <td></td>
                         <td><button type="button" class="btn btn-info" onclick="javascript:goWorkDbGrup();">업무DB 분류 선택</button></td>
                         <td></td>
                     </tr>
                  </tbody>
               </table>
            </div>


            <div class="contents" style="width:70%; float: left;" >
   <!-- 기본 -->
   			<h2>유틸성</h2>
               <table class="table-border">
           	   	<colgroup>
					<col width="200px">
					<col width="400px">
					<col width="">
				</colgroup>
               		<thead>
               		<th >기능</th>
               		<th >예시</th>
               		<th >설명</th>
               		</thead>
                  	<tbody>
                     <tr>
                    	 <td><label>주소팝업</label></td>
                    	<td><button type="button" class="btn btn-default" onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소팝업</button></td>
                    	<td></td>
                     </tr>
                     <tr>
                        <td>
                         <div class="input-group">
                           <!-- 옵션 설명은 HTML 작업 문서 참고 -->
                           <input type="text" style="width : 150px";
                              id="group_code"
                              name="group_code"
                              idfield="group_code"
                              easyui="combogrid"
                              header="Y"
                              easyuiname="groupCode"
                              panelwidth="220"
                              maxheight="155"
                              textfield="code_name"
                              multi="Y"/>

                        </div></td>
                    	<td><button type="button" class="btn btn-default" onclick="javascript:fnSetValue()">setValue</button></td>
                    	<td></td>
                     </tr>
                     <tr>
                        <td><label>getValue</label></td>
                    	<td><button type="button" class="btn btn-default" onclick="javascript:fnGetValue()">getValue</button></td>
                    	<td></td>
                     </tr>
                     <tr>
                        <td><label>format num</label></td>
                    	<td><input type="text" class="form-control" placeholder="format num" format="num" id="asdfasdf" name="asdfasdf" maxlength="8" style="width: 150px;"></td>
                    	<td></td>
                     </tr>
                     <tr>
                        <td><label>format decimal</label></td>
                    	<td><input type="text" class="form-control" placeholder="format decimal" format="decimal" id="jpy_basic" name="jpy_basic" maxlength="8" value="1234.1" style="width: 150px;"></td>
                    	<td></td>
                     </tr>
                     <tr>
                        <td><label>format phone</label></td>
                    	<td><input type="text" class="form-control" placeholder="format phone" format="phone" id="ddddd" name="ddddd" maxlength="11" style="width: 150px;"></td>
                    	<td></td>
                     </tr>
                     <tr>
                        <td><label>format date</label></td>
                        <td>
                        	<div class="input-group">
                            	<input type="text" class="form-control border-right-0 calDate" placeholder="dateFormat='yyyy-MM-dd'" dateFormat="yyyy-MM-dd" id="breg_open_dt" name="breg_open_dt" style="width: 110px;">
                        	</div>
                    	</td>
                    	<td></td>
                     </tr>
                     <tr>
                    	<td><input  type="text" class="form-control" placeholder="부품발주번호" id="part_order_no" name="part_order_no" maxlength="15" style="width: 150px;"></td>
                    	<td><button type="button" class="btn btn-default" onclick="javascript:fnSendPartOrderSpc();">부품발주번호 프로시저호출</button></td>
                    	<td></td>
                     </tr>
                     <tr>
                    	<td><input  type="text" class="form-control" placeholder="장비명" id="machine_name" name="machine_name" maxlength="15" style="width: 150px;" value="VIO35-6A-J"></td>
                    	<td><button type="button" class="btn btn-default" onclick="javascript:goModelInfoForCommon();">장비조회</button></td>
                    	<td></td>
                     </tr>
                     <tr>
                     	<td>직원조회</td>
                     	<td>
                     		<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
	                     		<jsp:param name="required_field" value=""/>
	                     		<jsp:param name="s_org_code" value=""/>
	                     		<jsp:param name="s_work_status_cd" value=""/>
 	                     		<jsp:param name="readonly_field" value=""/>
 	                     		<jsp:param name="execFuncName" value="fnMyExecFuncName"/>
 	                     		<jsp:param name="focusInFuncName" value=""/>
 	                     		<jsp:param name="focusInClearYn" value="Y"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span>필수체크 name="required_field" value="s_mem_no"</span><br>
                     		<span>부서 name="s_org_code" value="3000"</span><br>
                     		<span>재직상태 name="s_work_status_cd" value="01"</span><br>
                     		<span>readonly필드 name="readonly_field" value="s_org_code,s_work_status_cd"</span><br>
                     		<span>조회 후 실행함수 name="execFuncName" value="fnMyExecFuncName"</span><br>
                     		<span>포커스인 실행함수 name="focusInFuncName" value="fnMyFocusInFuncName"</span><br>
                     		<span>포커스인 내용삭제 여부 name="focusInClearYn" value="Y"</span><br>
                     	</td>

                     </tr>
                     <tr>
                     	<td>부품조회</td>
                    	<td>
                    		<jsp:include page="/WEB-INF/jsp/common/searchPart.jsp">
	                     		<jsp:param name="required_field" value="s_part_no,s_part_mng_cd"/>
	                     		<jsp:param name="s_cust_name" value=""/>
	                     		<jsp:param name="s_part_group_name" value=""/>
	                     		<jsp:param name="s_part_mng_cd" value="20"/>
	                     		<jsp:param name="s_only_warehouse_yn" value="Y"/>
	                     		<jsp:param name="s_warehouse_cd" value="6000"/>
	                     		<jsp:param name="readonly_field" value="s_part_mng_cd"/>
	                     		<jsp:param name="execFuncName" value=""/>
	                     		<jsp:param name="focusInFuncName" value=""/>
	                     		<jsp:param name="focusInClearYn" value="Y"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span>필수체크 name="required_field" value="s_part_no,s_part_mng_cd"</span><br>
                     		<span>매입처 name="s_cust_name" value="MANITOU ASIA"</span><br>
                     		<span>부품그룹 name="s_part_group_name" value="Engine assy 엔진"</span><br>
                     		<span>부품구분 name="s_part_mng_cd" value="20"</span><br>
                     		<span>창고부품만 조회 name="s_only_warehouse_yn" value="Y"</span><br>
                     		<span>창고번호 name="s_warehouse_cd" value="6000"</span><br>
                     		<span>readonly필드 name="readonly_field" value="s_part_mng_cd"</span><br>
                     		<span>조회 후 실행함수 name="execFuncName" value="fnMyExecFuncName"</span><br>
                     		<span>포커스인 실행함수 name="focusInFuncName" value="fnMyFocusInFuncName"</span><br>
                     		<span>포커스인 내용삭제 여부 name="focusInClearYn" value="Y"</span><br>
                     	</td>
                     </tr>
                     <tr>
                     	<td>
	                    	모델조회
                     	</td>
                     	<td>
	                     	<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
	                     		<jsp:param name="required_field" value=""/>
	                     		<jsp:param name="s_maker_cd" value=""/>
	                     		<jsp:param name="s_machine_type_cd" value=""/>
	                     		<jsp:param name="s_sale_yn" value=""/>
	                     		<jsp:param name="readonly_field" value=""/>
	                     		<jsp:param name="execFuncName" value=""/>
	                     		<jsp:param name="focusInFuncName" value=""/>
	                     		<jsp:param name="focusInClearYn" value="Y"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span>필수체크 name="required_field" value="s_machine_name"</span><br>
                     		<span>메이커 name="s_maker_cd" value="27"</span><br>
                     		<span>기종 name="s_machine_type_cd" value="20"</span><br>
                     		<span>거래정지미포함(기본값Y) name="s_sale_yn" value="N"</span><br>
                     		<span>readonly필드 name="readonly_field" value="s_maker_cd,s_machine_type_cd,s_sale_yn"</span><br>
                     		<span>조회 후 실행함수 name="execFuncName" value="fnMyExecFuncName"</span><br>
                     		<span>포커스인 실행함수 name="focusInFuncName" value="fnMyFocusInFuncName"</span><br>
                     		<span>포커스인 내용삭제 여부 name="focusInClearYn" value="Y"</span><br>
                     	</td>
                     </tr>
                     <tr>
                     	<td>사업자조회</td>
                     	<td>
                     		<jsp:include page="/WEB-INF/jsp/common/searchBreg.jsp">
	                     		<jsp:param name="required_field" value=""/>
	                     		<jsp:param name="s_breg_rep_name" value=""/>
	                     		<jsp:param name="s_breg_type_cd" value=""/>
 	                     		<jsp:param name="readonly_field" value=""/>
 	                     		<jsp:param name="execFuncName" value=""/>
 	                     		<jsp:param name="focusInFuncName" value=""/>
 	                     		<jsp:param name="focusInClearYn" value="Y"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span>필수체크 name="required_field" value="s_breg_no"</span><br>
                     		<span>대표자명 name="s_rep_name" value="박범재"</span><br>
                     		<span>사업자구분 name="s_breg_type_cd" value="PER"</span><br>
                     		<span>readonly필드 name="readonly_field" value="s_org_code,s_work_status_cd"</span><br>
                     		<span>조회 후 실행함수 name="execFuncName" value="fnMyExecFuncName"</span><br>
                     		<span>포커스인 실행함수 name="focusInFuncName" value="fnMyFocusInFuncName"</span><br>
                     		<span>포커스인 내용삭제 여부 name="focusInClearYn" value="Y"</span><br>
                     	</td>
                     </tr>
                     <tr>
                     	<td>고객사업자조회</td>
                     	<td>
                     		<input type="text" id="s_bcust_no" name="s_bcust_no" class="form-control width100px" value=""  placeholder="고객번호" alt="고객번호"  ><br>
                     		<jsp:include page="/WEB-INF/jsp/common/searchCustBreg.jsp">
	                     		<jsp:param name="required_field" value=""/>
	                     		<jsp:param name="cust_no_field_name" value="s_bcust_no"/>
 	                     		<jsp:param name="execFuncName" value=""/>
 	                     		<jsp:param name="focusInFuncName" value=""/>
 	                     		<jsp:param name="focusInClearYn" value="Y"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		고객번호 : 20190115124703136<br>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span>필수체크 name="required_field" value="s_cust_breg_no"</span><br>
                     		<span style="color:red;">고객번호fieldName</span><span> name="cust_no_field_name" value="s_bcust_no"</span><br>
                     		<span>조회 후 실행함수 name="execFuncName" value="fnMyExecFuncName"</span><br>
                     		<span>포커스인 실행함수 name="focusInFuncName" value="fnMyFocusInFuncName"</span><br>
                     		<span>포커스인 내용삭제 여부 name="focusInClearYn" value="Y"</span><br>
                     	</td>
                     </tr>
                     <tr>
                     	<td>고객조회</td>
                     	<td>
                     		<jsp:include page="/WEB-INF/jsp/common/searchCust.jsp">
	                     		<jsp:param name="required_field" value=""/>
 	                     		<jsp:param name="execFuncName" value=""/>
 	                     		<jsp:param name="focusInFuncName" value=""/>
 	                     		<jsp:param name="focusInClearYn" value="Y"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span>필수체크 name="required_field" value="s_cust_no"</span><br>
                     		<span>조회 후 실행함수 name="execFuncName" value="fnMyExecFuncName"</span><br>
                     		<span>포커스인 실행함수 name="focusInFuncName" value="fnMyFocusInFuncName"</span><br>
                     		<span>포커스인 내용삭제 여부 name="focusInClearYn" value="Y"</span><br>
                     	</td>
                     </tr>
                     <tr>
                     	<td>연관업무</td>
                     	<td>
                     		<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
 	                     		<jsp:param name="jobType" value="C"/>
 	                     		<jsp:param name="li_type" value="__ledger#__sms_popup#__sms_info#__visit_history#__check_required#__cust_rental_history#__rental_consult_history"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span style="color:red;">필수 파라미터 고객번호 name="__s_cust_no" value="20130603145119670"</span><br>
                     		<span style="color:red;">연관업무 구분 타입 name="jobType" value="고객:C, 부품:P, 장비:B"</span><br>
                     		<span style="color:red;">필요 list 파라미터 name="li_type" value="거래원장:__ledger, 문자발송:__sms_popup 등</span><br>
                     		<span>필요 list 파라미터 개별 추가</span><br>
                     		<span>고객명 name="__s_cust_name" value="장현석"</span><br>
                     		<span>고객 핸드폰 번호 name="__s_hp_no" value="01066003545"</span><br>
                     	</td>
                     </tr>
                     <tr>
                     	<td>연관업무(장비관련)</td>
                     	<td>
                     		<jsp:include page="/WEB-INF/jsp/common/commonMachineJob.jsp">
 	                     		<jsp:param name="li_machine_type" value="__body_no#__machine_detail#__repair_history#__machine_ledger#__as_todo#__campaign#__rental#__machine_doc_detail#__work_db"/>
	                     	</jsp:include>
                     	</td>
                     	<td>
                     		<span>&#60;jsp:param name="" value=""/&#62;</span><br>
                     		<span style="color:red;">차대번호 name="__s_body_no" value="4CR2-20627"</span> 필수 파라미터 (장비대장)<br>
                     		<span style="color:red;">장비대장번호 name="__s_machine_seq" value="42973"</span> 필수 파라미터 (장비대장 )<br>
                     		<span style="color:red;">고객번호 name="__s_cust_no" value="20130603145119670"</span> 필수 파라미터 (보유기중)<br>
                     		<span style="color:red;">품의서 번호 name="__s_machine_doc_no" value="2020-0106-01"</span> 필수 파라미터 ( 품의서)<br>
                     		<span style="color:red;">필요 list 파라미터 name="li_type" value="보유기종:__body_no, 장비대장:__machine_detail 등</span><br>
                     		<span>필요 list 파라미터 개별 추가</span><br>
                     		<span>고객명 name="__s_cust_name" value="장현석"</span><br>
                     	</td>
                     </tr>
                  </tbody>
               </table>
            </div>


            <div class="contents" style="width:30%; float: left;">
   <!-- 기본 -->
               <table class="table-border">
               <h2>조회 팝업</h2>
           	   	<colgroup>
					<col width="200px">
					<col width="240px">
					<col width="">
				</colgroup>
               		<thead>
               		<th >기능명</th>
               		<th >기능버튼</th>
               		</thead>
                  	<tbody>
                     <tr>
                        <td><label>담당자조회</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openSearchSaleAreaPanel('setSaleAreaInfo');">담당자조회</button></td>
                     </tr>
                     <tr>
                        <td><label>템플릿선택</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openSearchTemplatePanel('setTemplateInfo');">템플릿선택</button></td>
                     </tr>
                     <tr>
                        <td><label>장비대장관리</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openSearchDeviceHisPanel('fnSetDeviceHis');">장비대장관리</button></td>
                     </tr>
                     <tr>
                        <td><label>홍보파일참조</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openSearchPromoteFilePanel('setPromoteFileInfo');">홍보파일참조</button></td>
                     </tr>
					 <tr>
                        <td><label>정기검사 유효기간 안내</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openCheckCycleInfoPanel('setCheckCycleInfoPanel');">정기검사 유효기간 안내</button></td>
                     </tr>
                     <tr>
                        <td><label>조직도</label></td>
                    	<td>
                    		<button type="button" class="btn btn-info" onclick="javascript:openOrgMapPanel('setOrgMapPanel');">조직도</button>
                    		<button type="button" class="btn btn-info" onclick="javascript:openOrgMapCenterPanel('setOrgMapCenterPanel');">조직도(센터)</button>
                    		<button type="button" class="btn btn-info" onclick="javascript:openOrgMapAgencyPanel('setOrgMapAgencyPanel');">조직도(위탁판매점)</button>
                    	</td>
                     </tr>
					 <tr>
						 <td><label>직원조회(조직도)-단일</label></td>
						 <td>
							 <button type="button" class="btn btn-info" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'N');">직원조회(조직도)-단일</button>
						 </td>
					 </tr>
					 <tr>
						 <td><label>직원조회(조직도)-다중</label></td>
						 <td>
							 <button type="button" class="btn btn-info" onclick="javascript:openMemberOrgPanel('setMemberOrgMapPanel', 'Y');">직원조회(조직도)-다중</button>
						 </td>
					 </tr>
					 <tr>
					 	<td><label>조직도(메인)</label></td>
						 <td>
							 <button type="button" class="btn btn-info" onclick="javascript:openOrgMapMainPanel('setOrgMapMainPanel');">조직도(메인)</button>
						 </td>
					 </tr>
                     <tr>
                        <td><label>계정조회</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openAccountInfoPanel('setAccountInfoPanel');">계정조회</button></td>
                     </tr>
                     <tr>
                        <td><label>차량조회</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openCarInfoPanel('setCarInfo');">차량조회</button></td>
                     </tr>
                     <tr>
                        <td><label>예금조회</label></td>
                    	<td><button type="button" class="btn btn-info" onclick="javascript:openDepositInfoPanel('setDepositInfoPanel');">예금조회</button></td>
                     </tr>
                     <tr>
                  </tbody>
               </table>
            </div>


         </div>
      </div>
<!-- /contents 전체 영역 -->
</form>
</body>
</html>
