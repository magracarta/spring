<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > 견적서관리 > null > 렌탈견적서상세
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
-- 상세에서 장비, 고객변경 불가
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		var auiGrid;
		var isMachine = true;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnSetExpireDt();
			 fnChangeDeliveryCd();
			
			 if ("${inputParam.disabled_yn}" == "Y") {
				$("#main_form :input").prop("disabled", true);
				$("#main_form :button[onclick='javascript:fnClose();']").prop("disabled", false);
				$("#main_form :button[onclick='javascript:fnSendSms();']").prop("disabled", false);
			}
		});
		
		function fnSetExpireDt() {
			var rfqDt = $M.getValue("rfq_dt");
			$M.setValue("expire_dt", $M.addDates($M.toDate(rfqDt), 30));
			fnSetDayCnt();
		}
		
		// 어테치먼트 추가
	    function goAttachPopup() {
			var rentalMachineNo = $M.getValue("rental_machine_no");
			if (rentalMachineNo == "") {
				alert("장비를 먼저 선택해주세요");
				return false;
			}
			var rows = AUIGrid.getGridData(auiGrid);
	     	var params = {
	     		rental_machine_no : $M.getValue("rental_machine_no"),
	     		not_rental_attach_no : $M.getArrStr(rows, {key : 'rental_attach_no'}),
	     		mng_org_code : $M.getValue("rfq_org_code"),
				apply_yn : 'N',
		    };
	     	openRentalAttachPanel("fnSetAttach", $M.toGetParam(params));
	    }
		
		function fnSetAttach(row) {
			var item = new Object();
			if(row != null) {
				for(i=0; i<row.length; i++) {
					item.part_name = row[i].part_name;
					item.part_no = row[i].part_no;
					item.attach_name = row[i].attach_name;
					item.qty = 1;
					item.client_name = row[i].client_name;
					item.rental_attach_no = row[i].rental_attach_no;
					item.day_cnt = $M.getValue("day_cnt");
					item.amt = 0;
					item.cost_yn = row[i].cost_yn;
					item.base_yn = row[i].base_yn;
					item.product_no = row[i].product_no;
					AUIGrid.addRow(auiGrid, item, 'last');
				}
				getAttachPrice();
			}
			AUIGrid.resize(auiGrid);
		}
		
	    function getAttachPrice() {
	    	var rows = AUIGrid.getGridData(auiGrid);
	    	var dayCnt = $M.toNum($M.getValue("day_cnt"));
	    	if (rows.length < 1 || dayCnt == 0) {
	    		fnCalc();
	    		return false;
	    	}
	    	var dayArr = [];
	    	for (var i = 0; i < rows.length; ++i) {
	    		dayArr.push(dayCnt);
	    		AUIGrid.updateRow(auiGrid, {"day_cnt" : dayCnt },i);
	    	}
	    	var param = {
	    		rental_attach_no_str : $M.getArrStr(rows, {sep : "#", key : "rental_attach_no", isEmpty : true}),
	    		day_cnt_str : $M.getArrStr(dayArr),
	    		base_yn_str : $M.getArrStr(rows, {sep : "#", key : "base_yn", isEmpty : true}),
	    		cost_yn_str : $M.getArrStr(rows, {sep : "#", key : "cost_yn", isEmpty : true}),
	    	}
			$M.goNextPageAjax("/rent/rent010101/calc/attach", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			console.log(result);
			    			var total = 0;
			    			for (var i = 0; i < result.attachPrice.length; ++i) {
			    				total+=result.attachPrice[i];
			    				var obj = {
			    					amt :  result.attachPrice[i]
			    				}
			    				AUIGrid.updateRow(auiGrid, obj, i);
			    			}
			    			fnCalc();
						}
					}
				);
	    }
	    
		function fnCalc() {
			   var machine_rental_price = $M.toNum($M.getValue("machine_rental_price"));
			   var sumAttachAmt = 0;
			   var gridData = AUIGrid.getCheckedRowItemsAll(auiGrid);
			   for (var i = 0; i < gridData.length; ++i) {
				   var isRemoved = AUIGrid.isRemovedById(auiGrid, gridData[i]._$uid);
				   if (!isRemoved) {
					   sumAttachAmt+=$M.toNum(gridData[i].amt*gridData[i].qty);
				   }
			   }
			   var attach_rental_price = sumAttachAmt; // $M.toNum($M.getValue("attach_rental_price"));
			   $M.setValue("attach_rental_price", attach_rental_price);
			   var total_rental_amt = machine_rental_price + attach_rental_price;
			   var discount_amt = $M.toNum($M.getValue("discount_amt"));
			   var total_amt = total_rental_amt - discount_amt;
			   $M.setValue("total_rental_amt", total_rental_amt);
			   var transport_amt = $M.toNum($M.getValue("transport_amt"));
			   if ($M.getValue("rental_delivery_cd") == "03" || $M.getValue("rental_delivery_cd") == "04") {
				   total_amt += transport_amt;
			   } 
			   $M.setValue("total_amt", total_rental_amt+transport_amt);
			   $M.setValue("rental_amt", total_amt);
			   fnChangeDCAmt(1);
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn : false,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showSelectionBorder : true,
				rowCheckDisabledFunction: function (rowIndex, isChecked, item) {
					// 공지가 등록된 경우 체크 불가
					if (item.able_yn =='N') {
						return false;
					}

					return true;
				},
				independentAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					style : "aui-left"
				},
				{
					headerText : "총수량",
					dataField : "total_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "렌탈중",
					dataField : "rental_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "가용수량",
					dataField : "able_cnt",
					width : "80",
					style : "aui-center"
				},
				{
					headerText : "렌탈금액",
					dataField : "amt",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					visible : false,
				},
				// {
				// 	headerText : "삭제",
				// 	dataField : "h",
				// 	renderer : {
				// 		type : "ButtonRenderer",
				// 		onClick : function(event) {
				// 			if (event.item.rental_machine_no != null && event.item.rental_machine_no != "") {
				// 				AUIGrid.showToastMessage(auiGrid, event.rowIndex, 8, "기본어테치먼트는 삭제할 수 없습니다.");
				// 			} else {
				// 				var isRemoved = AUIGrid.isRemovedById(auiGrid, event.item._$uid);
				// 				if (isRemoved == false) {
				// 					AUIGrid.removeRow(event.pid, event.rowIndex);
				// 					fnCalc();
				// 				} else {
				// 					AUIGrid.restoreSoftRows(auiGrid, "selectedIndex");
				// 					getAttachPrice();
				// 				}
				// 			}
				// 		}
				// 	},
				// 	labelFunction : function(rowIndex, columnIndex, value,
				// 			headerText, item) {
				// 		return '삭제'
				// 	}
				// },
				{
					headerText : "수량",
					dataField : "qty",
					visible : false,
				},
				{
					headerText : "매입처",
					dataField : "client_name",
					visible : false,
				},
				{
					headerText : "일련번호",
					dataField : "product_no",
					visible : false,
				},
				{
					headerText : "렌탈일수",
					dataField : "day_cnt",
					visible : false,
				},
				{
					dataField : "rental_attach_no",
					visible : false
				},
				{
					dataField : "rental_machine_no",
					visible : false
				},
				{
					dataField : "base_yn",
					visible : false
				},
				{
					dataField : "cost_yn",
					visible : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${baseAttach});

			var base = ${attach};
			for(var i = 0; i < base.length; i++) {
				AUIGrid.addCheckedRowsByValue(auiGrid, "part_no", base[i].part_no);
			}

			AUIGrid.bind(auiGrid, "rowAllCheckClick", function( checked ) {
				if(checked) {
					AUIGrid.setCheckedRowsByValue(auiGrid, "able_yn", "Y");
				} else {
					AUIGrid.setCheckedRowsByValue(auiGrid, "part_no", "");
				}

				fnCalc();
			});
			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
				fnCalc();
			});
		}
		
		// 기본 조직도 조회
		function fnSetOrgMapPanel(row) {
			$M.setValue("rfq_org_name", row.org_name);
			$M.setValue("rfq_org_code", row.org_code);
			$M.goNextPageAjax("/rfq/office/"+row.org_code, "", {method : 'GET'},
				function(result) {
		    		if(result.success) {
		    			 var office = {
	    					 office_post_no : result.post_no,
	    					 office_addr1 : result.addr1,
	    					 office_addr2 : result.addr2,
	    					 office_fax_no : result.fax_no
		    			 }
		    			 $M.setValue(office);

						fnPhoneSetting(result); // 전화번호 셋팅
					}
				}
			);
		}

		// 견적사업장 전화번호 셋팅
		function fnPhoneSetting(result) {
			// 옵션 초기화
			$("#office_tel_no").children('option').remove();

			// 전화번호 배열 받기
			var originPhoneArr = [result.tel_no, result.service_tel_no, result.part_tel_no];
			var copyPhoneArr = [result.tel_no + " (전화 번호)", result.service_tel_no + " (서비스 담당자 번호)", result.part_tel_no + " (부품/렌탈 담당자 번호)"];

			// 배열 크기만큼 option 생성
			for (var i = 0; i < originPhoneArr.length; i++) {
				if (originPhoneArr[i] != '') { // 배열에 번호가 있다면
					console.log(originPhoneArr[i]);
					$("#office_tel_no").append('<option value="' + originPhoneArr[i] + '">' + copyPhoneArr[i] + '</option');
				}
			}
		}
		
		// 문자발송
		function fnSendSms() {
		   var param = {
				   'name' : $M.getValue('cust_name'),
				   'hp_no' : $M.getValue('hp_no')
		   }
		   openSendSmsPanel($M.toGetParam(param));
		}
		
		function fnSendMail() {
			if ($M.emailCheck($M.getValue("email1")+"@"+$M.getValue("email2")) == false) {
				alert("이메일이 올바르지 않습니다.");
				$("#email1").focus();
				return false;
			}
			var param = {
	    			 'to' : $M.getValue('email1')+"@"+$M.getValue('email2')
	    	  };
	        openSendEmailPanel($M.toGetParam(param));
		}
		
		function fnClose() {
			window.close(); 
		}	
		
		function goModify() {
			if($M.validation(document.main_form) == false) {
				return;
			}
			var email1 = $M.getValue("email1");
			var email2 = $M.getValue("email2");
			var beforeStr = email1+"@"+email2;
			var afterStr = beforeStr.split("@");
			if (email1 == "" && email2 != "") {
				$("#email1").focus();
				alert("올바른 이메일을 입력하세요");
				return false;
			}
			if (email1 != "" && email2 == "") {
				$("#email2").focus();
				alert("올바른 이메일을 입력하세요");
				return false;
			}
			if (afterStr[0] != "" && afterStr[1] != "") {
				var tempEmail = email1+"@"+email2;
				if (!$M.emailCheck(tempEmail)) {
					$("#email2").focus();
					alert("올바른 이메일을 입력하세요");
					return false;
				} else {
					$M.setValue("email", tempEmail);					
				}
			} else {
				$M.setValue("email", "");
			}
			
			$("input:checkbox[id='norm_rental_yn']").is(":checked") == false ? $M.setValue("norm_rental_yn", "N") : $M.setValue("norm_rental_yn", "Y");
	    	$("input:checkbox[id='long_rental_yn']").is(":checked") == false ? $M.setValue("long_rental_yn", "N") : $M.setValue("long_rental_yn", "Y");
	    	
	    	var frm = $M.toValueForm(document.main_form);
			var concatCols = [];
			var concatList = [];
			var gridFrm = fnCheckedGridDataToForm(auiGrid);
			// var gridIds = [auiGrid];
			// AUIGrid.removeSoftRows(auiGrid);
			// fnCalc();
			// for (var i = 0; i < gridIds.length; ++i) {
			// 	concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
			// 	concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			// }
			// var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);
			
			var rfqNo = $M.getValue("rfq_no");
			
			$M.goNextPageAjaxModify(this_page+"/"+rfqNo+"/modify", gridFrm, {method : 'POST'},
				function(result) {
					console.log(result);
			    	if(result.success) {
			    		alert("수정에 성공했습니다.");
			    		if (result.newRfqNo != null) {
			    			var param = {
			    				cust_no : result.custNo,
								rfq_no : result.newRfqNo
							}
			    			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=1100, left=0, top=0";
							$M.goNextPage('/cust/cust0107p04', $M.toGetParam(param), {popupStatus : poppupOption});
			    		} else {
			    			location.reload();
			    		}
					}
				}
			);
		}


		// 수주등록 버튼 추가
		function goNew() {
			var popupOption = "";
			var param = {
				"s_popup_yn" : "Y"
			}
			$M.goNextPage('/cust/cust020101', $M.toGetParam(param),  {popupStatus : popupOption});
		}
		
		//삭제
		function goRemove() {
			var rfqNo = $M.getValue("rfq_no");
			$M.goNextPageAjaxRemove(this_page+"/"+rfqNo+"/remove", '', {method : 'POST'},
				function(result) {
			    	if(result.success) {
			    		// 여기서 뒤로가기
			    		alert("삭제에 성공했습니다.");
			    		fnClose();
			    		if (opener != null && opener.goSearch) {
			    			opener.goSearch();
			    		}
					}
				}
			);
		}

		// 렌탈등록 버튼 추가
		function goNew() {
			var popupOption = "";
			var param = {
				"rental_machine_no" : $M.getValue("rental_machine_no"),
				"rfq_no" : $M.getValue("rfq_no"),
				"s_popup_yn" : "Y",
				"cust_no" : $M.getValue("cust_no"),
				"parent_js_name" : "fnSetGridData",
			}
			$M.goNextPage('/rent/rent010101', $M.toGetParam(param),  {popupStatus : popupOption});
		}

		function fnSetGridData(){
			var attachGridData = AUIGrid.getCheckedRowItemsAll(auiGrid);
			return attachGridData;
		}

		function goMailSend() {
			if ($M.emailCheck($M.getValue("email1")+"@"+$M.getValue("email2")) == false) {
				alert("이메일이 올바르지 않습니다.");
				$("#email1").focus();
				return false;
			}
			var param = {
					email : $M.getValue("email1")+"@"+$M.getValue("email2"),
					rfq_no : $M.getValue("rfq_no")
			};
			$M.goNextPageAjaxMsg("견적서를 메일로 전송하시겠습니까?\n전송 후 견적서 수정 시, 차수가 변경됩니다.","/rfq/delivery/mail", $M.toGetParam(param), {method : 'GET'},
				function(result) {
					openReportPanel('cust/cust0107p04_01.crf','rfq_no=' + $M.getValue("rfq_no") + '&cust_no=' + $M.getValue("cust_no"));
					var param = {
		    			 "to" : $M.getValue('email1')+"@"+$M.getValue('email2'),
		    			 "subject" : "[YK건기] "+$M.getValue("cust_name")+"님 "+$M.getValue("machine_name")+" 렌탈 견적서",
		    			 "body" : $M.getValue("cust_name")+"님 "+$M.getValue("machine_name")+" 렌탈견적서입니다.<br>"+"견적 상세내용은 첨부파일을 참고하세요."
		    	  	};
		        	openSendEmailPanel($M.toGetParam(param));
				}
			);
		}
		
		function goDocPrint() {
			var param = {
					rfq_no : $M.getValue("rfq_no")
			};
			$M.goNextPageAjaxMsg("견적서를 인쇄하시겠습니까?\n인쇄 후 견적서 수정 시, 차수가 변경됩니다.","/rfq/delivery/print", $M.toGetParam(param), {method : 'GET'},
				function(result) {
				openReportPanel('cust/cust0107p04_01.crf','rfq_no=' + $M.getValue("rfq_no") + '&cust_no=' + $M.getValue("cust_no"));
				}
			);
		}
		
	    function fnSetDayCnt() {
	    	if ($M.getValue("rental_st_dt") == "" || $M.getValue("rental_ed_dt") == "") {
	    		$M.setValue("day_cnt", 0);
	    	} else {
	        	var cnt = $M.getDiff($M.getValue("rental_ed_dt"), $M.getValue("rental_st_dt"));
	        	if (cnt < 1) {
	        		$M.setValue("rental_ed_dt", $M.getValue("rental_st_dt"));
	        		alert("렌탈 종료가 렌탈 시작 이전 입니다.");
	        		$M.setValue("day_cnt", 1);	
	        	} else {
	        		$M.setValue("day_cnt", cnt);
	        	}
	    	}
	    	if (isMachine) {
	    		getMachinePrice();
	    	}
	    }
	    
	    function getMachinePrice() {
	    	if ($M.getValue("day_cnt") == "" || $M.getValue("day_cnt") == "0") {
	    		return false;
	    	}
	    	var param = {
	    		rental_machine_no : $M.getValue("rental_machine_no"),
	    		day_cnt : $M.getValue("day_cnt")
	    	}
			$M.goNextPageAjax("/rent/rent010101/calc/machine", $M.toGetParam(param), {method : 'GET'},
					function(result) {
			    		if(result.success) {
			    			$M.setValue("machine_rental_price", result.price);
			    			getAttachPrice();
						}
					}
				);
	    }
		
		// 부가세는 할인액을 반영한 금액의 10%
		// 최종금액은 할인액을 반영한 금액에서 부가세를 더함
		// 할인액 변경
		function fnChangeDCAmt(i) {
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			var saveAmt;
			if(i == 1){
				saveAmt = $M.toNum($M.getValue("discount_amt"));
			}else{
				saveAmt = $M.toNum($M.getValue("temp_discount_amt"));
			}
			if (saveAmt > totalAmt) {
				alert("할인액은 금액("+$M.setComma(totalAmt)+")를 초과할 수 없습니다.");
				$M.setValue("discount_amt", totalAmt);
				$M.setValue("temp_discount_amt", totalAmt);
				fnChangeDCAmt(1);
				return false;
			}
			if (totalAmt == 0 || saveAmt == 0) {
				var vat = Math.floor(totalAmt*0.1);
				var calc = {
					rfq_amt :  $M.setComma(Math.round(totalAmt+vat)),
					vat : $M.setComma(vat),
					discount_rate : "0",
					discount_amt : "0",
					temp_discount_amt : "0",
					rental_amt : totalAmt,
				}
				$M.setValue(calc);
				return false;
			} else {
				var resultPrice = totalAmt-saveAmt;
				var saveRate = 100 - (resultPrice/totalAmt * 100);
				var vat = Math.floor(resultPrice*0.1);
				var calc = {
					rfq_amt : $M.setComma(Math.round(resultPrice+vat)),
					vat : $M.setComma(vat),
					discount_rate : saveRate,
					discount_amt : saveAmt,
					temp_discount_amt : saveAmt,
					rental_amt : resultPrice,
				}
				$M.setValue(calc);
			}
		}
		
		// 부가세는 할인액을 반영한 금액의 10%
		// 최종금액은 할인액을 반영한 금액에서 부가세를 더함
		// 할인율 변경
		function fnChangeDCRate() {
			var totalAmt = $M.toNum($M.getValue("total_amt"));
			var rate = $M.toNum($M.getValue("discount_rate"));
			if (rate > 100) {
				alert("할인율은 최대 100입니다.");
				$M.setValue("discount_rate", "100");
				fnChangeDCRate();
				return false;
			}
			if (totalAmt == 0 || rate == 0) {
				var vat = Math.floor(totalAmt*0.1);
				var calc = {
					rfq_amt : $M.setComma(Math.round(totalAmt+vat)),
					vat : $M.setComma(vat),
					discount_amt : "0",
					temp_discount_amt : "0",
					rental_amt : totalAmt,
				}
				$M.setValue(calc);
				return false;
			} else {
				var savePrice = totalAmt*rate/100;
				var resultPrice = totalAmt-savePrice;
				var vat = Math.floor(resultPrice*0.1);
				var calc = {
					rfq_amt : $M.setComma(Math.round(resultPrice+vat)),
					vat : $M.setComma(vat),
					discount_amt : $M.setComma(savePrice),
					temp_discount_amt : $M.setComma(savePrice),
					rental_amt : resultPrice,
				}
				$M.setValue(calc);
			}
		}
		
		function fnChangeDeliveryCd() {
	    	$(".two_way_yn").hide();
			var cd = $M.getValue("rental_delivery_cd");
			if (cd == "01") {
				$(".dc *").attr("disabled", true);
				$(".r1s").removeClass("rs");
			} else {
				$(".dc *").attr("disabled", false);
				$(".r1s").addClass("rs");
			}
			if (cd == "03" || cd == "04") {
				$("#transport_amt").prop('disabled', false);
				if (cd == "04") {
					alert("운송사 착불을 유도하고 불가피 할 경우에만 사용 하시고 수주매출로 따로 운송비처리하는 것을 금지합니다.");
				}
				if (cd == "03") {
					$(".two_way_yn").show();
				}
			} else {
				$M.setValue("transport_amt", "0");
				$("#transport_amt").prop('disabled', true);
			}
			fnCalc();
		}
		
		function fnSetArrival1Addr(row) {
	        var param = {
		        delivery_post_no: row.zipNo,
		        delivery_addr1: row.roadAddr,
		        delivery_addr2: row.addrDetail
	        };
	        $M.setValue(param);
	}
	</script>
</head>
<body class="bg-white" style="min-width: 1440px;">
<form id="main_form" name="main_form">
<input type="hidden" name="rfq_no" value="${rent.rfq_no}">
<input type="hidden" name="rfq_type_cd" value="${rent.rfq_type_cd }">
<input type="hidden" name="rfq_org_code" value="${rent.rfq_org_code }">
<input type="hidden" name="rfq_mem_no" value="${rent.rfq_mem_no }">
<input type="hidden" name="email" value="${rent.email }">

<!-- 팝업 -->
<div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
	<div class="main-title">
		<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	</div>
<!-- /타이틀영역 -->
	<div class="content-wrap">
<!-- 상단 폼테이블 -->					
		<div>
			<div class="title-wrap">
				<h4>렌탈견적서상세</h4>
				<div>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>			
				</div>
			</div>
			<table class="table-border">
				<colgroup>
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right">견적번호</th>
						<td>
							<div class="form-row inline-pd">
								<div class="col-3">
									<input type="text" class="form-control" readonly="readonly" value="${fn:split(rent.rfq_no,'-')[0]}">
								</div>
								<div class="col-auto">-</div>
								<div class="col-3">
									<input type="text" class="form-control" readonly="readonly" value="${fn:split(rent.rfq_no,'-')[1]}">
								</div>
							</div>
						</td>	
						<th class="text-right rs">견적일자</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 width120px calDate rb" id="rfq_dt" name="rfq_dt" dateFormat="yyyy-MM-dd" value="${rent.rfq_dt}" alt="견적일자" required="required" onchange="javascript:fnSetExpireDt()">
							</div>
						</td>	
						<th class="text-right">업체명</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" id="breg_name" name="breg_name" value="${rent.breg_name}">
						</td>	
						<th class="text-right">대표자</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" id="breg_rep_name" name="breg_rep_name" value="${rent.breg_rep_name}">
						</td>									
					</tr>
					<tr>
						<th class="text-right rs">고객명</th>
						<td>
							<div>
								<input type="text" class="form-control width120px" readonly="readonly" id="cust_name" name="cust_name" required="required" alt="고객명" value="${rent.cust_name}">
								<!-- <button type="button" class="btn btn-icon btn-primary-gra" disabled="disabled"><i class="material-iconssearch"></i></button> -->
								<input type="hidden" id="cust_no" name="cust_no" value="${rent.cust_no}">							
							</div>
						</td>	
						<th class="text-right rs">휴대폰</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 width140px rb" id="hp_no" name="hp_no" format="phone" required="required" alt="휴대폰" value="${rent.hp_no}" disabled="disabled">
								<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendSms();" ><i class="material-iconsforum"></i></button>
							</div>
						</td>	
						<th class="text-right">사업자번호</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" id="breg_no" name="breg_no" value="${rent.breg_no}">
						</td>	
						<th class="text-right">현미수</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width120px">
									<input type="text" class="form-control text-right width120px" readonly="readonly" id="misu_amt" name="misu_amt" value="${rent.misu_amt}">
								</div>
								<div class="col-1">원</div>
							</div>
							
						</td>									
					</tr>
					<tr>
						<th class="text-right">전화</th>
						<td>
							<input type="text" class="form-control width140px" readonly="readonly" id="tel_no" name="tel_no" value="${rent.tel_no}">
						</td>	
						<th class="text-right">팩스</th>
						<td>
							<input type="text" class="form-control width140px" readonly="readonly" id="fax_no" name="fax_no" value="${rent.fax_no}">
						</td>	
						<th class="text-right" rowspan="2">주소</th>
						<td colspan="3" rowspan="2">
							<div class="form-row inline-pd mb7">
								<div class="width100px" style="padding-left: 5px; padding-right: 5px">
									<input type="text" class="form-control" readonly="readonly" id="post_no" name="post_no" value="${rent.post_no}">
								</div>
								<div class="col" style="width: calc(100% - 100px)">
									<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1" value="${rent.addr1}">
								</div>
							</div>
							<div class="form-row inline-pd">
								<div class="col-12">
									<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2" value="${rent.addr2}">
								</div>		
							</div>
						</td>
					</tr>
					<tr>
						<th class="text-right">이메일</th>
						<td>
							<div class="form-row inline-pd widthfix">
								<div class="col width100px">
									<input type="text" class="form-control" id="email1" name="email1" value="${fn:split(rent.email,'@')[0]}">
								</div>
								<div class="col width16px text-center">@</div>
								<div class="col width100px">
									<input type="text" class="form-control" id="email2" name="email2" value="${fn:split(rent.email,'@')[1]}">
								</div>	
								<div class="col" style="width: calc(100% - 216px)">
									<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSendMail();"><i class="material-iconsmail"></i></button>	
								</div>									
							</div>
						</td>	
						<th class="text-right rs">유효기간</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0 width120px calDate rb" id="expire_dt" name="expire_dt" required="required" alt="유효기간" dateFormat="yyyy-MM-dd" value="${rent.expire_dt}">
							</div>
						</td>	
					</tr>										
				</tbody>
			</table>
		</div>
		<!-- 장비정보 -->
		<div>
			<div class="title-wrap mt10">
				<h4>장비정보</h4>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right rs">모델</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control border-right-0" readonly="readonly" id="machine_name" name="machine_name" required="required" alt="모델명" value="${rent.machine_name}">
								<button type="button" class="btn btn-icon btn-primary-gra" disabled="disabled"><i class="material-iconssearch"></i></button>							
							</div>
						</td>
						<th class="text-right">메이커</th>
						<td>
							<input type="text" class="form-control" readonly="readonly" id="maker_name" name="maker_name" value="${rent.maker_name}">
							<input type="hidden" id="maker_cd" name="maker_cd" value="${rent.maker_cd}">
						</td>
						<th class="text-right rs">연식</th>
						<td>
							<div class="form-row inline-pd widthfix">
                                <div class="col width60px">
                                    <input type="text" class="form-control text-right" id="made_dt" name="made_dt" readonly="readonly" value="${rent.made_dt }">
                                </div>
                                <div class="col width28px">
                                    	년식
                                </div>
                            </div>
                        </td>
                        <th class="text-right">가동시간</th>
                        <td>
						<div class="form-row inline-pd widthfix">
                                 <div class="col width60px">
                                     <input type="text" class="form-control text-right" readonly="readonly" id="op_hour" name="op_hour" format="decimal" value="${rent.op_hour }">
                                 </div>
                                 <div class="col width28px">
                                     	시간
                                 </div>
                             </div>
                         </td>
					</tr>
					<tr>
						<th class="text-right">차대번호</th>
						<td>
							<input type="text" class="form-control" readonly="readonly" id="body_no" name="body_no" value="${rent.body_no }">
						</td>
						<th class="text-right">번호판번호</th>
						<td>
							<input type="text" class="form-control" readonly="readonly" id="mreg_no" name="mreg_no" value="${rent.mreg_no }">
						</td>
						<th class="text-right">GPS</th>
						<td colspan="3">
							<c:choose>
								<c:when test="${not empty rent.sar }">
									SA-R
								</c:when>
								<c:otherwise>
									<input type="hidden" id="gps_seq" name="gps_seq" value="${item.gps_seq}" >
									<div class="form-row inline-pd widthfix">
										<div class="col width33px text-right">
											종류
										</div>
										<div class="col width100px">
											<select class="form-control" id="gps_type_cd" name="gps_type_cd" disabled="disabled">
												<option value="">- 선택 -</option>
												<c:forEach items="${codeMap['GPS_TYPE']}" var="codeitem">
													<option value="${codeitem.code_value}" ${rent.gps_type_cd eq codeitem.code_value ? 'selected="selected"' : ''}>${codeitem.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col width60px text-right">
											개통번호
										</div>
										<div class="col width140px">
											<input type="text" class="form-control" readonly="readonly" id="gps_no" name="gps_no" value="${rent.gps_no}">
										</div>
									</div>
								</c:otherwise>
							</c:choose>
						</td>							
					</tr>
				</tbody>
			</table>						
		</div>
<!-- /장비정보 -->	
		<div>
			<div class="title-wrap mt10">
				<h4>견적사업장</h4>
			</div>
			<table class="table-border mt5">
				<colgroup>
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
					<col width="100px">
					<col width="">
				</colgroup>
				<tbody>
					<tr>
						<th class="text-right rs">부서</th>
						<td>
							<div class="input-group">
								<input type="text" class="form-control width120px border-right-0" id="rfq_org_name" name="rfq_org_name" readonly="readonly" value="${rent.rfq_org_name }" alt="부서" required="required">
								<button type="button" class="btn btn-icon btn-primary-gra width120px" onclick="javascript:openOrgMapPanel('fnSetOrgMapPanel');" ><i class="material-iconssearch"></i></button>						
							</div>
						</td>
						<th class="text-right rs">견적자</th>
						<td>
							<input type="text" class="form-control width120px" readonly="readonly" id="rfq_mem_name" name="rfq_mem_name" value="${rent.rfq_mem_name}">
						</td>
						<th class="text-right">전화</th>
						<td>
							<select class="form-control width280px" id="office_tel_no" name="office_tel_no">
								<c:forEach var="item" items="${origin_office_phone}" varStatus="status">
									<c:if test="${save_office_tel_no eq ''}">
										<option value="" selected></option>
									</c:if>
									<c:if test="${save_office_tel_no eq item}">
										<option value="${item}" selected>${copy_office_phone[status.index]}</option>
									</c:if>
									<c:if test="${save_office_tel_no ne item}">
										<option value="${item}">${copy_office_phone[status.index]}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th class="text-right">팩스</th>
						<td>
							<input type="text" class="form-control width140px" readonly="readonly" id="office_fax_no" name="office_fax_no" value="${rent.office_fax_no }">
						</td>								
					</tr>
					<tr>
						<th class="text-right">주소</th>
						<td colspan="3">
							<div class="form-row inline-pd mb7">
								<div class="width100px" style="padding-left: 5px; padding-right:5px;">
									<input type="text" class="form-control" readonly="readonly" id="office_post_no" name="office_post_no" value="${rent.office_post_no}">
								</div>
								<div class="col" style="width: calc(100% - 110px)">
									<input type="text" class="form-control" readonly="readonly" id="office_addr1" name="office_addr1" value="${rent.office_addr1}">
								</div>
							</div>
							<div class="form-row inline-pd">
								<div class="col">
									<input type="text" class="form-control" readonly="readonly" id="office_addr2" name="office_addr2" value="${rent.office_addr2}">
								</div>		
							</div>
						</td>	
						<th class="text-right">특이사항</th>
						<td colspan="3">
							<textarea class="form-control" style="height: 97px; resize: none;" id="memo" name="memo">${rent.memo}</textarea>
						</td>
					</tr>
				</tbody>
			</table>					
		</div>
<!-- /상단 폼테이블 -->	
		<div class="row mt10">
            <div class="col-6">
<!-- 렌탈정보 -->
                <div class="title-wrap approval-left">
                    <h4>렌탈정보</h4>
                </div>			
                <table class="table-border mt5">
                    <colgroup>
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
						<col width="100px">
						<col width="">
                    </colgroup>
                    <tbody>
                        <tr>
                            <th class="text-right">관리번호</th>
                            <td colspan="3">
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width110px">
                                        <input type="text" class="form-control" readonly="readonly" id="rental_machine_no" name="rental_machine_no" value="${rent.rental_machine_no }">
                                    </div>
                                </div>
                            </td>	
                            <th class="text-right">마케팅 담당자</th>
                            <td colspan="3">
                                <input type="text" class="form-control width100px" readonly="readonly" id="sale_mem_name" name="sale_mem_name" value="${rent.sale_mem_name}">
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right rs">렌탈기간</th>
                            <td colspan="7">
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width120px">
                                        <div class="input-group">
                                            <input type="text" class="form-control rb border-right-0 calDate" id="rental_st_dt" name="rental_st_dt" dateFormat="yyyy-MM-dd" onchange="fnSetDayCnt()" required="required" alt="렌탈 시작일" value="${rent.rental_st_dt}">
                                        </div>
                                    </div>
                                    <div class="col width16px text-center">~</div>
                                    <div class="col width120px">
                                        <div class="input-group">
                                            <input type="text" class="form-control rb border-right-0 calDate" id="rental_ed_dt" name="rental_ed_dt" dateFormat="yyyy-MM-dd" onchange="fnSetDayCnt()" required="required" alt="렌탈 종료일" value="${rent.rental_ed_dt}">
                                        </div>
                                    </div>
                                    <div class="col width50px text-right">
                                        <input type="text" class="form-control" readonly="readonly" id="day_cnt" name="day_cnt" value="${rent.day_cnt}">
                                    </div>
                                    <div class="col width16px">
                                        	일
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
							<th class="text-right rs">인도방법</th>
							<td colspan="3">
								<select class="form-control width130px rb inline" id="rental_delivery_cd" name="rental_delivery_cd" required="required" alt="인도방법" onchange="javascript:fnChangeDeliveryCd()">
									<option value="">- 선택 -</option>
									<c:forEach items="${codeMap['RENTAL_DELIVERY']}" var="item">
										<option value="${item.code_value}" <c:if test="${item.code_value eq rent.rental_delivery_cd}">selected="selected"</c:if>>${item.code_name}</option>
									</c:forEach>
								</select>
								<div style="display: inline-block; vertical-align: middle; margin-left: 5px;">
									<div class="two_way_yn" style="display: none;">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="two_way_yn_n" name="two_way_yn" value="N" <c:if test="${rent.two_way_yn == 'N'}">checked="checked"</c:if>>
											<label class="form-check-label" for="two_way_yn_n">편도</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" id="two_way_yn_y" name="two_way_yn" value="Y" <c:if test="${rent.two_way_yn == 'Y'}">checked="checked"</c:if>>
											<label class="form-check-label" for="two_way_yn_y">왕복</label>
										</div>
									</div>
								</div>
							</td>
							<th class="text-right">임차구분</th>
							<td>
								<div colspan="3">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="norm_rental_yn" value="Y" <c:if test="${rent.norm_rental_yn == 'Y'}">checked="checked"</c:if>>
										<label class="form-check-label" for="norm_rental_yn">일반</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="long_rental_yn" value="Y" <c:if test="${rent.long_rental_yn == 'Y'}">checked="checked"</c:if>>
										<label class="form-check-label" for="long_rental_yn">장기</label>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right r1s">배송지</th>
							<td colspan="7">
								<div class="form-row inline-pd dc">
                                       <div class="col-1 pdr0">
                                           <input type="text" class="form-control mw45" readonly="readonly"
                                                  id="delivery_post_no" name="delivery_post_no"
                                                  value="${rent.delivery_post_no}" alt="배송지 우편번호">
                                       </div>
                                       <div class="col-auto pdl5">
                                           <button type="button" class="btn btn-primary-gra full"
                                                   onclick="javascript:openSearchAddrPanel('fnSetArrival1Addr');">주소찾기
                                           </button>
                                       </div>
                                       <div class="col-5">
                                           <input type="text" class="form-control" readonly="readonly"
                                                  id="delivery_addr1" name="delivery_addr1"
                                                  value="${rent.delivery_addr1}">
                                       </div>
                                       <div class="col-4">
                                           <input type="text" class="form-control" id="delivery_addr2"
                                                  name="delivery_addr2" value="${rent.delivery_addr2}">
                                       </div>
                                   </div>											
							</td>
						</tr>
						<tr>
							<th class="text-right rs">실 사용지역</th>
							<td colspan="3">
								<div>
									<select class="form-control width130px rb inline" id="sale_area_code" name="sale_area_code" required="required" alt="실 사용지역">
										<option value="">- 선택 -</option>
										<c:forEach items="${areaList}" var="item">
											<option value="${item.sale_area_code}" <c:if test="${item.sale_area_code eq rent.sale_area_code}">selected="selected"</c:if>>${item.sale_area_name}</option>
										</c:forEach>
									</select>
								</div>
							</td>
							<th class="text-right rs">장비용도</th>
							<td>
								<div>
									<select class="form-control rb" id="mch_use_cd" name="mch_use_cd" required="required"alt="장비용도">
										<option value="">- 선택 -</option>
										<c:forEach items="${codeMap['MCH_USE']}" var="mchItem">
											<option value="${mchItem.code_value}" <c:if test="${mchItem.code_value eq rent.mch_use_cd}">selected="selected"</c:if>>${mchItem.code_name}</option>
										</c:forEach>
									</select>
								</div>
							</td>
							<th class="text-right">사용목적</th>
							<td>
								<div>
									<input type="text" class="form-control" maxlength="50" alt="" id="use_purpose" name="use_purpose" value="${rent.use_purpose }">
								</div>
							</td>
						</tr>
						<tr>
							<%-- <th class="text-right">최소렌탈료</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="min_rental_price" name="min_rental_price" format="decimal" value="${rent.min_rental_price }">
									</div>
									<div class="col width16px">원</div>
								</div>									
							</td> --%>
							<th class="text-right">장비렌탈료</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="machine_rental_price" name="machine_rental_price" format="decimal" value="${rent.machine_rental_price }">
									</div>
									<div class="col width16px">원</div>
									(A)
								</div>									
							</td>
							<th class="text-right">어태치렌탈료</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="attach_rental_price" name="attach_rental_price" format="decimal" value="${rent.attach_rental_price}">
									</div>
									<div class="col width16px">원</div>
									(B)
								</div>									
							</td>
						</tr>
						<tr>
							<th class="text-right">총 렌탈료</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="total_rental_amt" name="total_rental_amt" format="decimal" value="${rent.total_rental_amt }">
									</div>
									<div class="col width16px">원</div>
									(A+B)
								</div>									
							</td>
							<th class="text-right">렌탈료조정</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="discount_amt" name="discount_amt" format="minusNum" value="${rent.discount_amt}" onchange="javascript:fnCalc()">
									</div>
									<div class="col width16px">원</div>
									(C) 양수=할인, 음수=할증
								</div>									
							</td>
						</tr>
						<tr>
							<th class="text-right">운임비</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" format="decimal" value="${rent.transport_amt}" onchange="javascript:fnCalc()" disabled="disabled">
									</div>
									<div class="col width16px">원</div>
									<span style="color: red">(D) 직배송,선결제시 최종렌탈료에 합산</span>
								</div>
							</td>
							<th class="text-right">최종렌탈료</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="rental_amt" name="rental_amt" format="decimal" value="${rent.rental_amt}">
									</div>
									<div class="col width16px">원</div>
								</div>									
							</td>
						</tr>
						<tr>
							<th class="text-right">비고</th>
							<td colspan="7">
								<textarea class="form-control" style="height: 100%; min-height: 70px" id="remark" name="remark">${rent.remark }</textarea>
							</td>
						</tr>
                        <%-- <tr>
                            <th class="text-right">최소렌탈료</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" readonly="readonly" id="min_rental_price" name="min_rental_price" value="${rent.min_rental_price}" format="decimal">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>									
                            </td>
                            <th class="text-right">장비렌탈료</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" readonly="readonly" id="machine_rental_price" name="machine_rental_price" value="${rent.machine_rental_price}" format="decimal">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>									
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">어테치렌탈료</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" readonly="readonly" id="attach_rental_price" name="attach_rental_price" value="${rent.attach_rental_price}" format="decimal">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>									
                            </td>
                            <th class="text-right">총 렌탈료</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" readonly="readonly" id="total_rental_price" name="total_rental_price" format="decimal">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>									
                            </td>
                        </tr>
                        <tr>
                            <th class="text-right">최종렌탈료</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" readonly="readonly" id="total_rental_price" name="total_rental_price" value="${rent.rfq_amt }" format="decimal">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>									
                            </td>
                        </tr> --%>
                    </tbody>
                </table>			
<!-- /렌탈정보 -->	
            </div>
            <div class="col-6">
<!-- 어테치먼트 -->
                <div class="title-wrap">
                    <h4>어테치먼트</h4>
					<button type="button" class="btn btn-primary-gra" onclick="javascript:goAttachPopup();">어테치먼트 현황</button>
                </div>
                <div id="auiGrid" style="margin-top: 5px; height: 415px;"></div>					
<!-- /어테치먼트 -->	
            </div>
        </div>
<!-- 합계그룹 -->
		<div class="row inline-pd mt10">
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="40%">
						<col width="60%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">수량</th>
							<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="total_qty" name="total_qty" value="1" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="40%">
						<col width="60%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">금액</th>
							<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" value="${rent.total_amt }" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="40%">
						<col width="60%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">할인율(%)</th>
							<td class="text-right"><input type="text" class="form-control text-right" id="discount_rate" name="discount_rate" value="${rent.discount_rate }" onchange="fnChangeDCRate()" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="40%">
						<col width="60%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">할인액</th>
							<td class="text-right"><input type="text" class="form-control text-right" id="discount_amt" name="temp_discount_amt" value="${rent.discount_amt }" onchange="fnChangeDCAmt()" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>  
						<tr>
							<th class="text-right th-sum">부가세</th>
							<td class="text-right td-gray"><input type="text" class="form-control text-right" readonly="readonly" id="vat" name="vat" value="0" format="decimal"></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="col-2">
				<table class="table-border">
					<colgroup>
						<col width="50%">
						<col width="50%">
					</colgroup>
					<tbody>
						<tr>
							<th class="text-right th-sum">총 견적금액</th>
							<td class="text-right td-gray"><div data-tip="(금액-할인액)*VAT"><input type="text" class="form-control text-right" readonly="readonly" id="rfq_amt" name="rfq_amt" value="${rent.rfq_amt }" format="decimal"></div></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
<!-- /합계그룹 -->
<!-- 그리드 서머리, 컨트롤 영역 -->
		<div class="btn-group mt5">						
			<div class="right">
				<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/><jsp:param name="mem_no" value="${rfq_mem_no}"/></jsp:include>
			</div>
		</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
	</div>
</div>

</form>
</body>
</html>