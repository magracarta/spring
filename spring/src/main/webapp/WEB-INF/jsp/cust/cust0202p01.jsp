<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 매출처리 > null > 매출처리상세
-- 작성자 : 박예진
-- 최초 작성일 : 2020-04-28 09:08:26
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var inoutYn = "";
		var partReturnResultCd = "${partReturnResultCd}"; // 부품반품처리상태
		var isDelivery = false;
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			fnInitPage();
			$("#_goTransPart").addClass("dpn"); // 22.11.21 이원영파트장님 요청으로 부품일괄이동요청 버튼 미노출로 변경

		});

		function fnInitPage() {

			var basicInfo = ${info}.basicInfo;
			var partList = ${info}.partList;
			var partSaleInfo = ${info}.partSaleInfo;

			$M.setValue(basicInfo);
			$M.setValue("__s_cust_name", basicInfo.cust_name);
			$M.setValue("__s_cust_no", basicInfo.cust_no);
			$M.setValue("__s_hp_no", basicInfo.cust_hp_no);

			//문자메세지 참조시 사용
			$M.setValue("__s_req_msg_yn", "Y");								//내용참조 여부
			$M.setValue("__s_menu_seq", ${menu_seq});						//내용참조 메뉴
			$M.setValue("__s_menu_param", $M.getValue("inout_doc_no") );	//내용참조 메뉴파라미터

			$M.setValue("old_coupon_amt", basicInfo.discount_amt);
			$M.setValue("old_mile_amt", basicInfo.use_mile_amt);

			if(partSaleInfo != null){
				$M.setValue("app_yn", partSaleInfo.app_yn);
				$M.setValue("invoice_desc_text", partSaleInfo.invoice_desc_text);
			}

			AUIGrid.setGridData("#auiGrid", partList);

			// 값에 따라 데이터 세팅
			fnSetPage(basicInfo);
			// 마감, 회계전송여부, 국세청신고여부에 따라 화면 변경
			fnChangeStatus(basicInfo);
		}

		function fnSetPage(list) {
			// 렌탈 매출처리일 경우 삭제 버튼 hide
// 			if(list.inout_doc_type_cd == "11") {
// 				$("#_goRemove").addClass("dpn");
// 			}
			// 수주 매출처리가 아니면 버튼 hide
			if(list.inout_doc_type_cd != "05") {
				$("#_goPartReturn").addClass("dpn");
			}
			// 수동매칭 버튼 hide
			$("#_goMapping").addClass("dpn");
			$("#_goMappingRemove").addClass("dpn");

			// 고객에 매핑된 사업자가 다수인 경우 처리
			$M.setValue("check_breg_no", list.breg_no);
// 			if($M.getValue("check_breg_yn") == "Y") {
// 				var text = list.breg_no + ' ' + '외' + ' ' + list.count_breg_no;
// 				$M.setValue("check_breg_no", text);
// 				$("#check_breg_no").css("color", "red");
// 			} else {
// 				$M.setValue("check_breg_no", list.breg_no);
// 			}

			// 부가구분이 합계면 합산발행만 표시
			if($M.getValue("add_ut") == "T" && $M.getValue("vat_treat_cd") == "S") {
				// $(".add-u").addClass("dpn");
				$("#vat_treat_s").prop("checked", true);
			}
			// else if ($M.getValue("add_ut") == "T" && $M.getValue("vat_treat_cd") != "S") {
			// 	$(".add-n").addClass("dpn");
			// 	$(".vatTreat" + $M.getValue("vat_treat_cd")).removeClass("dpn");
			// }
			else {
				$(".vatTreatAll").removeClass("dpn");
			}
			// 수정계산서, 렌탈, 마이너스
			if($M.getValue("taxbill_send_cd") == "5" && $M.getValue("doc_amt") < 0 && "${page.fnc.F00788_001}" != "Y") {
				$("#vat_treat_y").prop("disabled", true);
				// $(".add-f").removeClass("dpn");
				$("#vat_treat_f").prop("checked", true);
				$M.setValue("early_return_yn", "Y");
			}

			if($M.getValue("vat_treat_cd") == "Y" && $M.getValue("taxbill") == "") {
				$(".vat_treat").prop("checked", false);
			}

			// 선주문 Y일 시 부품일괄이동요청 버튼 숨김 (일반 수주, 정비에만 노출)
			if ($M.getValue("preorder_yn") == "N" && ($M.getValue("inout_doc_type_cd") == "05" || $M.getValue("inout_doc_type_cd") == "07")) {
				$("#_goTransPart").removeClass("dpn");
			} else {
				$("#_goTransPart").addClass("dpn");
			}

			// VIP 판매가 관련 추가
			if (list.vip_yn == "Y") {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText : "단가(VIP)",
					width : "8%",
					headerStyle : "aui-vip-header",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				});
			} else {
				// 단가 헤더 속성값 변경하기
				AUIGrid.setColumnProp(auiGrid, 6, {
					headerText : "단가(일반)",
					width : "8%",
					headerStyle : "aui-vip-header",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				});
			}

			// 선주문일 시 선주문 표시 추가
			if($M.getValue("preorder_yn") == "Y") {
				$("#preorder_inout").text("※선주문전표");
			}

			// 3차 Q&A 14336 2022-11-08 김상덕
			// 수정계산서는 마이너스 일때만 활성
			if("${page.fnc.F00788_001}" != "Y") { // 3차 14336. 관리부일 경우 모든 처리구분 노출. 2023-01-16 정윤수
				if (list.doc_amt < 0) {
					$("#vat_treat_f").prop("disabled", false);
					$("#vat_treat_y").prop("disabled", true);
				} else {
					$("#vat_treat_f").prop("disabled", true);
					$("#vat_treat_y").prop("disabled", false);
				}
			}
			// 장비일 경우 상세 보기용으로만 비활성화
			if(list.inout_doc_type_cd == "08" && "${page.fnc.F00788_001}" != "Y") {
				$("#main_form :input").prop("disabled", true);
				$("#main_form :button").prop("disabled", false);
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			}

			// 무증빙일경우 전표분리 버튼 노출 (관리부만)
			if ($M.getValue("vat_treat_cd") != "N" || "${page.fnc.F00788_001}" != "Y") {
				$("#goInoutDocDivBtn").addClass("dpn");
			}

			// 2023-10-18 황빛찬 - 아래로직 주석처리 후 fnChangeStatus 하단으로 이동함.
			<%--var tempYn = "${inputParam.temp_yn}";--%>
			<%--var basicInfo = ${info}.basicInfo  ;--%>
			<%--// 해당 전표가 임시전표면 수정불가하고 열람만 가능--%>
			<%--// if(tempYn == "Y"){--%>
			<%--if(tempYn == "Y" || basicInfo.cust_app_yn == "Y"){--%>
			<%--	$("#_goArsInoutDocPopup").addClass("dpn");--%>
			<%--	$("#_goBregInfoPopup").addClass("dpn");--%>
			<%--	$("#_goTransPart").addClass("dpn");--%>
			<%--	$("#_goRemove").addClass("dpn");--%>
			<%--	$("#_goModify").addClass("dpn");--%>
			<%--	$("#_goInoutPopup").addClass("dpn");--%>
			<%--	// $("#_goDeliveryInfo").addClass("dpn");--%>
			<%--	$("#_goPartReturn").addClass("dpn");--%>
			<%--	$('input').prop('disabled', true);--%>
			<%--	$('select').prop('disabled', true);--%>
			<%--	$('.textbox-icon').bind('click', false);--%>
			<%--}--%>
			<%--// 고객앱에서 화물로 주문한 경우 대신화물 영업소명 노출--%>
			<%--if(basicInfo.cust_app_yn == "Y" && $M.getValue("inout_doc_type_cd") == "05" && basicInfo.invoice_send_cd == "5"){--%>
			<%--	var partSaleInfo = ${info}.partSaleInfo;--%>
			<%--	$M.setValue("invoice_addr", partSaleInfo.desc_text);--%>
			<%--}--%>
			<%--// 마이너스 전표(반품 or 조기회수)일 경우, 마일리지사용금액 수정 불가--%>
			<%--if ($M.toNum($M.getValue("doc_amt")) < 0){--%>
			<%--	$("#use_mile_amt").prop("disabled", true);--%>
			<%--	// 반품환불 버튼 미노출--%>
			<%--	$("#_goPartReturn").addClass("dpn");--%>
			<%--}--%>
		}


		function goSendPaper() {

			// 품명 외 몇건
// 	     	var gridData = AUIGrid.getGridData(auiGrid);

// 			if(gridData.length != 0) {
// 				var gridLength = gridData.length - 1;
// 		     	var partName = gridData[0].item_name;
// 		     	if(gridLength <= 0) {
// 		     		$M.setValue("count_remark", partName);
// 		     	} else {
// 		     		$M.setValue("count_remark", partName + " 외 " + gridLength + "건");
// 		     	}
// 			}


// 			var paperContents = "【 부품발송요청 】#"
// 				+	"전표번호 : " + $M.getValue("inout_doc_no") + "#"
// 				+	"고 객 명 : " + $M.getValue("cust_name") + "(" + $M.getValue("cust_hp_no") + ")" + "#"
// 				+	"품    목 : " + $M.getValue("count_remark") + "#"
// 				+	"발송구분 : " + $M.getValue("invoice_send_name") + $M.getValue("invoice_money_name") +"#"
// 				+	"발 송 지 : " + $M.getValue("invoice_addr") + $M.getValue("receive_name") + "(" + $M.getValue("receive_hp_no") + ")" + "#"
// 				+	"적    요 : " + $M.getValue("desc_text");

			var paperContents = "【 해당 매출 참조 요청건 】#"
				+	"고 객 명 : " + $M.getValue("cust_name") + "(" + $M.getValue("cust_hp_no") + ")" + "#"
				+	"전표번호 : " + $M.getValue("inout_doc_no") + "#"
				+	"요청사항 : #"
				+ "####"
				+	"자료조회버튼으로 참조자료를 확인하십시오 ." + "#";

			$M.setValue("paper_send_yn", "Y");
			$M.setValue("paper_contents", paperContents);


			var option = {
					isEmpty : true
			};

			var jsonObject = {
					"paper_send_yn" : $M.getValue("paper_send_yn"),
					"paper_contents" : $M.getValue("paper_contents"),
					"ref_key" : $M.getValue("inout_doc_no"),
 					"receiver_mem_no_str" : "",	// 참조자
 					"refer_mem_no_str" : "",		// 수신자
 					"menu_seq" : "${page.menu_seq}",
 					"pop_get_param" : "inout_doc_no="+$M.getValue("inout_doc_no")
			}
			openSendPaperPanel(jsonObject);
		}

		function fnChangeStatus(check) {
			var reportYn = check.report_yn;
			var endYn = check.end_yn;
			var transYn = check.duzon_trans_yn;
			var custAppYn = check.cust_app_yn;
			var payCashYn = check.pay_cash_yn; // 23.11.22 현금영수증 발행 여부

			if(endYn == "Y" && transYn == "Y") {
				inoutYn = "N";
				$(".end_check").addClass("dpn");
			    $(".trans_check").removeClass("dpn");
			    $("#main_form :input").prop("disabled", true);
				$("#main_form :button").prop("disabled", false);
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			    $(".dis_check").prop("disabled", true);
			    $(".vat_treat").prop("disabled", true);
			    $("#_goBregInfoPopup").prop("disabled", true);
			    $("#_goDeliveryInfo").prop("disabled", true);
			    $('#inout_org_code').combogrid('disable');
			} else if (endYn == "Y" && transYn == "N") {
				inoutYn = "N";
				$(".trans_check").addClass("dpn");
			    $(".end_check").removeClass("dpn");
			    $("#main_form :input").prop("disabled", true);
				$("#main_form :button").prop("disabled", false);
				$("#_goModify").addClass("dpn");
				$("#_goRemove").addClass("dpn");
			    $(".dis_check").prop("disabled", true);
			    $(".vat_treat").prop("disabled", true);
			    $("#_goBregInfoPopup").prop("disabled", true);
			    $("#_goDeliveryInfo").prop("disabled", true);
			    $('#inout_org_code').combogrid('disable');
			} else {
				inoutYn = "Y";
				$(".trans_check").addClass("dpn");
			    $(".end_check").addClass("dpn");
			    $("#_goModify").show();
			    $("#_goRemove").show();
			}

			if(reportYn == "Y") {
		    	alert("세금계산서가 이미 신고된 건으로 수정/삭제가 불가합니다.");
		    	inoutYn = "N";
			    $(".dis_check").prop("disabled", true);
			    $(".vat_treat").prop("disabled", true);
			    $("#_goBregInfoPopup").prop("disabled", true);
			    $("#_goDeliveryInfo").prop("disabled", true);
			    $('#inout_org_code').combogrid('disable');
		    	$("#_goModify").hide();
			    $("#_goRemove").hide();
		    }

			// 3차 14336. 관리부일경우 마감 상관없이 처리구분 수정가능. 2022-11-11 김상덕
			if (endYn == "Y" && transYn == "N" && ${page.fnc.F00788_001 eq 'Y'}) {
				$M.setValue("endModiYn", "Y");
				$(".vat_treat").prop("disabled", false);
				$("#main_form :button").prop("disabled", false);
				$("#_goModify").removeClass("dpn");
				// $("#_goRemove").removeClass("dpn");
			}
			// 회계이관, 마감, 고객앱주문 중 부품수주이면서 반품수주가 아닌경우 수동매칭버튼 노출
			if((transYn == 'Y' || endYn == "Y" || custAppYn == "Y") && $M.getValue("inout_doc_type_cd") == "05" && $M.toNum($M.getValue("doc_amt")) >= 0){
				$("#_goMapping").removeClass("dpn");
				// 이미 수동매칭 되어있다면 매칭해제버튼 노출
				if($M.getValue("bill_no") != ""){
					$("#_goMappingRemove").removeClass("dpn");
				}
			}
            if(payCashYn == 'Y'){
              $(".cash").prop('disabled', false);
            }

			var tempYn = "${inputParam.temp_yn}";
			var basicInfo = ${info}.basicInfo  ;
			// 해당 전표가 임시전표면 수정불가하고 열람만 가능
			// if(tempYn == "Y"){
			if(tempYn == "Y" || basicInfo.cust_app_yn == "Y"){
				$("#_goArsInoutDocPopup").addClass("dpn");
				$("#_goBregInfoPopup").addClass("dpn");
				$("#_goTransPart").addClass("dpn");
				$("#_goRemove").addClass("dpn");
				$("#_goModify").addClass("dpn");
				$("#_goInoutPopup").addClass("dpn");
				// $("#_goDeliveryInfo").addClass("dpn");
				// $("#_goPartReturn").addClass("dpn");
				$('input').prop('disabled', true);
				$('select').prop('disabled', true);
				$('.textbox-icon').bind('click', false);
			}
            // 임시전표가 아니고 관리부면 세금계산서 처리구분 수정가능
            if(tempYn != "Y" && "${page.fnc.F00788_001}" == "Y"){
              $(".vat_treat").prop("disabled", false);
              $("#main_form :button").prop("disabled", false);
              $("#_goModify").removeClass("dpn");
            }
			// 고객앱에서 화물로 주문한 경우 대신화물 영업소명 노출
			if(basicInfo.cust_app_yn == "Y" && $M.getValue("inout_doc_type_cd") == "05" && basicInfo.invoice_send_cd == "5"){
				var partSaleInfo = ${info}.partSaleInfo;
				$M.setValue("invoice_addr", partSaleInfo.desc_text);
			}
			// 마이너스 전표(반품 or 조기회수)일 경우, 마일리지사용금액 수정 불가
			if ($M.toNum($M.getValue("doc_amt")) < 0){
				$("#use_mile_amt").prop("disabled", true);
				// 반품환불 버튼 미노출
				$("#_goPartReturn").addClass("dpn");
			}
            if(basicInfo.pay_cash_yn == 'Y'){
              $(".cash").prop('disabled', false);
              $("#_goPayCash").removeClass("dpn");
            }else{
              $(".cash").prop('disabled', true);
              $("#_goPayCash").addClass("dpn");
            }
		}

		// 참조상세
		function goReferDetailPopup() {
			var params = {};
			var popupOption = "";
			switch($M.getValue("inout_doc_type_cd")) {
			case "05" : params = {
							"part_sale_no" : $M.getValue("part_sale_no"),
							"cust_no" : $M.getValue("cust_no")
						};
				$M.goNextPage('/cust/cust0201p01', $M.toGetParam(params), {popupStatus : popupOption});
				break;
			case "07" : params = {
							"s_job_report_no" : $M.getValue("job_report_no")
						};
				$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus : popupOption});
				break;
			case "08" : params = {
							"machine_doc_no" : $M.getValue("machine_doc_no")
						};
				$M.goNextPage('/sale/sale0101p03', $M.toGetParam(params), {popupStatus : popupOption});
				break;
			case "11" : params = {
							"rental_doc_no" : $M.getValue("rental_doc_no")
						};
			popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
			$M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});
				break;
			case "12" : params = {
							"machine_used_no" : $M.getValue("machine_used_no")
						};
				$M.goNextPage('/acnt/acnt0408p01', $M.toGetParam(params), {popupStatus : popupOption});
				break;
			case "13" : params = {
							"rental_machine_no" : $M.getValue("rental_machine_no")
						};
				$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
				break;
			}
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "item_id",
				// No. 제거
				showRowNumColumn: true,
				editable : false,
				showStateColumn : true,
				showFooter : true,
				footerPosition : "top"
			};

			if(inoutYn == "N") {
				gridPros.editable = false;
			}
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "item_id",
					width : "10%",
					style : "aui-center",
					editable : false
				},
				{
					headerText : "부품명",
					dataField : "item_name",
					width : "24%",
					style : "aui-left",
					editable : false
				},
				{
					headerText : "단위",
					dataField : "unit",
					width : "6%",
					style : "aui-center",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? "-" : value;
					},
				},
				{
					headerText : "현재고",
					dataField : "stock_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-center aui-popup",
					editable : false,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
			            return value == "" || value == null ? 0 : $M.setComma(value);
					},
				},
				{
					headerText : "수량",
					dataField : "qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "6%",
					style : "aui-center",
					editable : false,
				},
				{
					dataField : "old_qty",
					visible : false
				},
				{
					headerText : "단가",
					dataField : "unit_price",
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-right",
					editable : false
				},
				{
					headerText : "금액",
					dataField : "amt",
					width : "8%",
					dataType : "numeric",
					formatString : "#,##0",
					editable : false,
					style : "aui-right",
					expFunction : function(  rowIndex, columnIndex, item, dataField ) {
						// 수량 * 단가 계산
						return ( item.qty * item.unit_price );
					}
				},
				{
					headerText : "비고",
					dataField : "dtl_desc_text",
					width : "25%",
					style : "aui-left",
					editable : false
				},
				{
					headerText : "미처리량",
					dataField : "sale_mi_qty",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
					editable : false,
// 					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
// 			            return value == "" || value == null ? 0 : $M.setComma(value);
// 					},
				},
				{
					dataField : "part_no",
					visible : false
				},
				{
					dataField : "seq_no",
					visible : false
				},
			];
			var footerColumnLayout = [
				{
					labelText : "합계",
					positionField : "item_id",
					style : "aui-center aui-footer",
					colSpan : 5
				},
				{
					dataField : "unit_price",
					positionField : "unit_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				},
				{
					dataField : "amt",
					positionField : "amt",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer",
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellEditEnd", function( event ) {
				if(event.dataField == 'qty'){
					var qty = event.value;
					var totalQty = event.item["sale_mi_qty"] + event.item["old_qty"];
					if(qty > totalQty) {
						alert("남은 발주수량보다 큰 수량을 입력할 수 없습니다.\n" + totalQty + "보다 작거나 같은 수량을 입력하십시오.");
						AUIGrid.updateRow(auiGrid, { "qty" : totalQty }, event.rowIndex);
						return false;
					}
				}
			});
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				// 현재고 셀 클릭 시 부품재고상세 팝업 호출
				 if(event.dataField == 'stock_qty') {
					var param = {
							"part_no" : event.item["item_id"]
					};
					var popupOption = "";
					$M.goNextPage('/part/part0101p01', $M.toGetParam(param),  {popupStatus : popupOption});
				};
			});
		}

		// 사업자변경
		function goBregInfoPopup() {
			fnSearchBregSpec();
		}

		// 사업자명세조회
	    function fnSearchBregSpec() {
	    	if($M.getValue("cust_no") == "") {
	    		alert("매출처리할 건을 참조 후 이용해주세요.");
	    		$(".vat_treat").prop('checked', false);
	    		return false;
	    	}
	    	var param = {
	    			 's_cust_no' : $M.getValue('cust_no')
	    	};
	    	openSearchBregSpecPanel('fnSetBregSpec', $M.toGetParam(param));
	    }

		// 사업자명세 정보 call back
	    function fnSetBregSpec(row) {
	        var param = {
	        	"breg_name" : row.breg_name,
	        	"breg_no" : row.breg_no,
	        	"real_breg_no" : row.real_breg_no,
// 	        	"check_breg_no" : row.breg_no + ' ' + '외' + ' ' + $M.getValue("count_breg_no"),
	        	"check_breg_no" : row.breg_no,
	        	"breg_rep_name" : row.breg_rep_name,
	        	"breg_cor_type" : row.breg_cor_type,
	        	"breg_cor_part" : row.breg_cor_part,
	        	"breg_seq" : row.breg_seq,
	        	"biz_post_no" : row.biz_post_no,
	        	"biz_addr1" : row.biz_addr1,
	        	"biz_addr2" : row.biz_addr2,
	        	"biz_addr" : row.biz_post_no + ' ' + row.biz_addr1 + ' ' + row.biz_addr2
	        };

	        $M.setValue(param);

	    }

		// 배송정보 팝업
	    function goDeliveryInfo() {
	    	if ($M.getValue("cust_no") == "") {
				alert("매출처리할 건을 참조 후 이용해주세요.");
				$M.setValue("invoice_send_cd", "");
				return false;
			}
	    	var params = {
	    			cust_no : $M.getValue("cust_no"),
	    			invoice_money_cd : $M.getValue("invoice_money_cd"),
	    			invoice_send_cd : $M.getValue("invoice_send_cd"),
	    			receive_name : $M.getValue("receive_name"),
	    			invoice_no : $M.getValue("invoice_no"),
	    			receive_hp_no : $M.getValue("receive_hp_no"),
	    			receive_tel_no : $M.getValue("receive_tel_no"),
	    			qty : $M.getValue("invoice_qty"),
	    			remark : $M.getValue("invoice_remark"),
	    			post_no : $M.getValue("invoice_post_no"),
	    			addr1 : $M.getValue("invoice_addr1"),
	    			addr2 : $M.getValue("invoice_addr2"),
	    			invoice_type_cd : $M.getValue("invoice_type_cd"),
					bill_no : $M.getValue("bill_no"), // 대신화물 송장번호
	    			app_yn : $M.getValue("app_yn"),
	    			invoice_desc_text : $M.getValue("invoice_desc_text"),
	    	};

	    	openDeliveryInfoPanel('setDeliveryInfo', $M.toGetParam(params));
	    }

	    // 배송정보 callback
	    function setDeliveryInfo(data) {
	    	$M.setValue(data);
	    	$M.setValue("invoice_addr", data.invoice_post_no + ' ' + data.invoice_addr1 + ' ' + data.invoice_addr2);
	    }

		// 대신화물 수동매칭
		function goMapping(){
			param = {
				parent_js_name : "fnSetDsInvoice"
			};

			var poppupOption = "";
			$M.goNextPage('/cust/cust0201p08', $M.toGetParam(param), {popupStatus : poppupOption});
		}

		function fnSetDsInvoice(row){
			var frm = document.main_form;
			$M.setValue(frm, "bill_no", row.bill_no); // 대신화물 송장번호
			goSaveDsInvoices();
		}
		// 대신화물 송장번호 업데이트
		function goSaveDsInvoices(){
			var param = {
				"part_sale_no" : $M.getValue("part_sale_no"),
				"bill_no" : $M.getValue("bill_no"),
				"send_invoice_seq" : $M.getValue("send_invoice_seq")
			}
			$M.goNextPageAjax(this_page + "/invoice/save", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("수동매칭이 완료되었습니다.");
							location.reload();
						}
					}
			);
		}
	    function goMappingRemove() {
			var param = {
				"part_sale_no" : $M.getValue("part_sale_no"),
				"bill_no" : "",
				"send_invoice_seq" : $M.getValue("send_invoice_seq")
			}
			var msg = "매칭을 해제하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/invoice/save", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("매칭이 해제되었습니다.");
							location.reload();
						}
					}
			);
		}
	    // 수정
		function goModify() {
			var frm = document.main_form;
	     	var gridData = AUIGrid.getGridData(auiGrid);

			if($M.getValue("inout_org_code") == "") {
				alert("처리센터는 필수입력입니다.");
				return false;
			}
			if($M.getValue("invoice_send_cd") == "") {
				alert("배송정보설정으로 배송지주소를 설정해주십시오.");
				return false;
			}
			if($M.getValue("vat_treat_cd") == "") {
				alert("처리구분을 선택해주세요.");
				return false;
			}

			if($M.validation(frm) === false) {
	     		return;
	     	};

			/*
	     	// 세금계산서 시 사업자번호가 없으면 리턴
	     	if($M.getValue("breg_no") == "" && $M.getValue("vat_treat_cd") == "Y") {
	     		alert("사업자번호 및 업체명을 확인 후 처리 하세요.");
	     		return false;
	     	}

			// 이유경 카톡: 무증빙, 카드, 현금영수증 3건에대한 미수금에만 해당. 2022-12-05. 김상덕
			if($M.getValue("vat_treat_cd") == "N" || $M.getValue("vat_treat_cd") == "C" || $M.getValue("vat_treat_cd") == "A") {
				// 2022-12-02 (SR:14336) 미수가 없을경우 사업자 체크하지않고 수정 가능.
				// 사업자가 없는 고객에게 건별처리로 매출처리 X --> 선 입금처리 후 매출처리하라는 알림
				// if($M.getValue("breg_no") == "" || $M.getValue("check_breg_no") == "") {
				var calcAmt = 0;
				// calcAmt = $M.toNum($M.getValue("total_amt")) + $M.toNum($M.getValue("misu_amt"));
				if($M.toNum($M.getValue("misu_amt")) > 0) {
					alert("사업자 번호 및 미수금을 확인하십시오.\n미 사업자고객의 경우 입금처리 후 매출처리 하시기 바랍니다.");
					return false;
				}
				// }
			}
			*/

			/*
			* (Q&A14336) 2022-12-08 김상덕
			* [매출 등록], [매출 상세 수정]
			* 세금계산서(Y), 합산(S), 수정(F) : 사업자번호 있어야함, 미수 상관없음
			* 카드(C), 현금영수증(A) : 사업자번호 유무 상관없음, 미수금 상관없음
			* 무증빙(N) : 사업자번호 유무 상관없음, 과입금만큼만 매출발행 가능
			* */
			var taxArr = ["Y", "S", "F"];
			var checkedVatTreatCd = $M.getValue("vat_treat_cd");
			if (taxArr.includes(checkedVatTreatCd)) {
				if ($M.getValue("breg_no") == "") {
					alert("사업자번호 및 업체명을 확인 후 처리 하세요.");
					return false;
				}
			} else if (checkedVatTreatCd == "N") {
				var calcAmt = 0;
				calcAmt = $M.toNum($M.getValue("misu_amt"));
				if (calcAmt > 0) {
					alert("미수금을 확인하십시오.\n미 사업자고객의 경우 입금처리 후 매출처리 하시기 바랍니다.");
					return false;
				}
			}


			frm = $M.toValueForm(document.main_form);

			var seq_no_arr = [];
			var item_id_arr = [];
			var item_name_arr = [];
			var unit_arr = [];
			var stock_qty_arr = [];
			var qty_arr = [];
			var unit_price_arr = [];
			var amt_arr = [];
			var storage_name_arr = [];
			var current_all_qty_arr = [];
			var desc_text_arr = [];

			for (var i = 0; i < gridData.length; i++) {
				seq_no_arr.push(gridData[i].seq_no);
				item_id_arr.push(gridData[i].item_id);
				item_name_arr.push(gridData[i].item_name);
				unit_arr.push(gridData[i].unit);
				stock_qty_arr.push(gridData[i].stock_qty);
				qty_arr.push(gridData[i].qty);
				unit_price_arr.push(gridData[i].unit_price);
				amt_arr.push(gridData[i].amt);
				storage_name_arr.push(gridData[i].storage_name);
				current_all_qty_arr.push(gridData[i].current_all_qty);
				desc_text_arr.push(gridData[i].dtl_desc_text);
			}

// 			if($M.getValue("inout_doc_type_cd") != "12" && $M.getValue("inout_doc_type_cd") != "13") {
// 				// 선주문에 따라 count_remark 세팅도 변경
// 		     	var gridLength = item_name_arr.length - 1;

// 		     	if ( gridLength >= 0 ) {
// 		     		var partName = item_name_arr[0];
// 		     		if(gridLength <= 0) {
// 			     		$M.setValue("count_remark", partName);
// 			     	} else {
// 			     		$M.setValue("count_remark", partName + " 외 " + gridLength + "건");
// 			     	}
// 		     	}
// 			}

			var option = {
					isEmpty : true
			};

			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no_arr, option));
			$M.setValue(frm, "item_id_str", $M.getArrStr(item_id_arr, option));
			$M.setValue(frm, "item_name_str", $M.getArrStr(item_name_arr, option));
			$M.setValue(frm, "unit_str", $M.getArrStr(unit_arr, option));
			$M.setValue(frm, "stock_qty_str", $M.getArrStr(stock_qty_arr, option));
			$M.setValue(frm, "qty_str", $M.getArrStr(qty_arr, option));
			$M.setValue(frm, "unit_price_str", $M.getArrStr(unit_price_arr, option));
			$M.setValue(frm, "amt_str", $M.getArrStr(amt_arr, option));
			$M.setValue(frm, "storage_name_str", $M.getArrStr(storage_name_arr, option));
			$M.setValue(frm, "current_all_qty_str", $M.getArrStr(current_all_qty_arr, option));
			$M.setValue(frm, "dtl_desc_text_str", $M.getArrStr(desc_text_arr, option));

	     	var msg = "";

			// (Q&A 14336) Re33 (4) "[A]에서 [B]로 변경하시겠습니까" 로 수정. 2023-01-27 김상덕
			var oldVatTreatCd = ${info}.basicInfo.vat_treat_cd;
			var newVatTreatCd = $M.getValue("vat_treat_cd");
			if (oldVatTreatCd != newVatTreatCd) {

				var vatTreatCodeMap = JSON.parse('${codeMapJsonObj["VAT_TREAT"]}');
				vatTreatCodeMap.push({code_value : "F", code_name : "수정계산서"});

				var oldVatTreatName = vatTreatCodeMap.find(item => item.code_value == oldVatTreatCd).code_name;
				console.log(oldVatTreatCd+"#"+oldVatTreatName);
				var newVatTreatName = vatTreatCodeMap.find(item => item.code_value == newVatTreatCd).code_name;
				console.log(newVatTreatCd+"#"+newVatTreatName);
				// msg = confirm("["+oldVatTreatName + "]에서 [" + newVatTreatName + "]으로 변경하시겠습니까");
				msg = "["+oldVatTreatName + "]에서 [" + newVatTreatName + "]으로 변경하시겠습니까";
				if (confirm(msg) == false) {
					return false;
				} else {
					if (oldVatTreatCd == 'N') {
						if (confirm("처리구분 변경시 해당 전표의 분리전표가 있는경우 모두 삭제됩니다.\n진행 하시겠습니까 ?") == false) {
							return false;
						} else {
							$M.setValue(frm, "vat_treat_cd_change_yn", "Y");
						}
					}
				}
			} else {
				// if($M.getValue("taxbill") != "") {
				// 	msg = confirm("매출처리 및 세금계산서 처리가 완료된 건입니다.\n이미 발행된 세금계산서는 삭제처리 되므로 재발행 처리해야 합니다.\n세금계산서 재처리 하시겠습니까?");
				// 	if(!msg) {
				// 		return false;
				// 	}
				// }

				switch($M.getValue("vat_treat_cd")) {
				case "Y" : msg = confirm("매출전표 및 세금계산서를 발행하시겠습니까?");
						break;
				case "N" : msg = confirm("무증빙처리 하시겠습니까?");
						break;
				// case "R" : msg = confirm("사업자를 추후에 등록하고 매출처리 하시겠습니까?");
				// 		break;
				case "S" : msg = confirm("합산발행 매출처리 하시겠습니까?");
						break;
				case "F" : msg = confirm("수정계산서 매출처리 하시겠습니까?");
						break;
				case "C" : msg = confirm("카드매출처리 하시겠습니까?");
						break;
				case "A" : msg = confirm("현금영수증처리 하시겠습니까?");
						break;
				default : alert("세금계산서 처리구분을 반드시 선택하십시오.");
						return false;
						break;
				}
			}

			if(!msg) {
				return false;
			}

	     	// 부품 수량이 0인 row가 있으면 confirm창 띄우기 2021-06-28 황빛찬
			var qtyValid = false;
			for (var i = 0; i < qty_arr.length; i++) {
				if (qty_arr[i] == 0) {
					qtyValid = true;
				}
			}

			if (qtyValid) {
				if (confirm("부품 입력수량이 0인 항목(부품)이 있습니다. \n계속 진행 하시겠습니까 ?") == false) {
					return false;
				}
			}

			$M.goNextPageAjax(this_page + "/modify", frm, {method : 'POST', timeout : 60 * 60 * 1000},
				function(result) {
			    	if(result.success) {
			    		var popupOption = "";
			    		// 매출처리(수주) 팝업 오픈
			    		var param = {
			    				"inout_doc_no" : result.inout_doc_no,
			    				"early_return_yn" : $M.getValue("early_return_yn")
			    		};
						$M.goNextPage('/cust/cust0202p04', $M.toGetParam(param), {popupStatus : popupOption});

						window.location.reload();
					}
				}
			);
		}

	    // 삭제
// 	    function goRemove() {
// 			var frm = document.main_form;

// 	     	var gridData = AUIGrid.getGridData(auiGrid);
// 			frm = $M.toValueForm(document.main_form);

// 			var seq_no_arr = [];
// 			var item_id_arr = [];
// 			var qty_arr = [];

// 			for (var i = 0; i < gridData.length; i++) {
// 				seq_no_arr.push(gridData[i].seq_no);
// 				item_id_arr.push(gridData[i].item_id);
// 				qty_arr.push(gridData[i].qty);
// 			}

// 			var option = {
// 					isEmpty : true
// 			};

//  			$M.setValue(frm, "item_id_str", $M.getArrStr(item_id_arr, option));
//  			$M.setValue(frm, "qty_str", $M.getArrStr(qty_arr, option));
//  			$M.setValue(frm, "seq_no_str", $M.getArrStr(seq_no_arr, option));

// 			$M.goNextPageAjaxRemove(this_page + '/remove', frm , {method : 'POST'},
// 				function(result) {
// 					if(result.success) {
// 						alert("삭제가 완료되었습니다.");
// 						fnClose();
// 						<c:if test="${not empty inputParam.parent_js_name}">
// 				    		if (opener.${inputParam.parent_js_name}) {
// 			    				opener.${inputParam.parent_js_name}();
// 			    			}
// 		    			</c:if>
// 		    			<c:if test="${empty inputParam.parent_js_name}">
// 		    				if (opener != null && opener.goSearch) {
// 		    					opener.goSearch();
// 		    				}
// 		    			</c:if>
// 					}
// 				}
// 			);
// 		}

	    // 삭제
	    function goRemove() {

	    	var param = {
	    			"inout_doc_no" : $M.getValue("inout_doc_no"),
	    			"cust_no" : $M.getValue("cust_no"),
	    			"send_invoice_seq" : $M.getValue("send_invoice_seq"),
	    			"inout_doc_type_cd" : $M.getValue("inout_doc_type_cd"),
					"part_sale_no" : $M.getValue("part_sale_no"),
					"job_report_no" : $M.getValue("job_report_no"),
					"rental_doc_no" : $M.getValue("rental_doc_no"),
					"total_amt": $M.getValue("total_amt")
	    	}

			$M.goNextPageAjaxRemove(this_page + '/remove', $M.toGetParam(param) , {method : 'POST', timeout : 60 * 60 * 1000},
				function(result) {
					if(result.success) {
						alert("삭제가 완료되었습니다.");

						<c:if test="${not empty inputParam.parent_js_name}">
				    		if (opener.${inputParam.parent_js_name}) {
			    				opener.${inputParam.parent_js_name}();
			    			}
		    			</c:if>
		    			<c:if test="${empty inputParam.parent_js_name}">
		    				if (opener != null && opener.goSearch) {
		    					opener.goSearch();
		    				}
		    			</c:if>

		    			fnClose();
					}
				}
			);
		}
	    function goPayCash() {
			
			var param = {
				"cust_no" : $M.getValue("cust_no"),
				"id_info" : $M.getValue("id_info"),
				"buyr_name" : $M.getValue("buyr_name"),
				"buyr_mail" : $M.getValue("buyr_mail"),
				"tr_code" : $M.getValue("tr_code"),
				"mul_no" : $M.getValue("mul_no"),
				"inout_doc_no" : $M.getValue("inout_doc_no"),
			}
			var msg = "현금영수증을 수동발행하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + '/payCash', $M.toGetParam(param) , {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("현금영수증 발행이 완료되었습니다.");
						}
						window.location.reload();
					}
			);
		}

		function fnCalcCoupon() {
			var couponAmt = $M.toNum($M.getValue("coupon_balance_amt") + $M.getValue("old_coupon_amt"));
			if(couponAmt < $M.toNum($M.getValue("discount_amt"))) {
				alert("쿠폰 잔액보다 더 큰 쿠폰 금액을 사용할 수 없습니다.");
				$M.setValue("discount_amt", 0);
			}

			var applyDiscountAmt = 0;

			if($M.toNum($M.getValue("doc_amt")) < 0){
				applyDiscountAmt = $M.toNum($M.getValue("doc_amt"))-$M.toNum($M.getValue("discount_amt"));
			} else {
				applyDiscountAmt = $M.toNum($M.getValue("doc_amt"))-$M.toNum($M.getValue("discount_amt"))-$M.toNum($M.getValue("use_mile_amt"));
			}
			$M.setValue("apply_discount_amt", applyDiscountAmt);
			var vatAmt = $M.toNum($M.getValue("apply_discount_amt"))*0.1;
			$M.setValue("vat_amt", vatAmt);
			var totalAmt = $M.toNum($M.getValue("apply_discount_amt"))+$M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt);
		}

		function fnCalcMile() {
			var mileAmt = $M.toNum($M.getValue("mile_balance_amt")) + $M.toNum($M.getValue("old_mile_amt"));
			if(mileAmt < $M.toNum($M.getValue("use_mile_amt"))) {
				alert("마일리지 잔액보다 더 큰 마일리지 금액을 사용할 수 없습니다.");
				$M.setValue("use_mile_amt", 0);
			}

			// 반품 건일 경우, 할인적용가 계산하지 않음
			if ($M.toNum($M.getValue("doc_amt")) >= 0) {
				var applyDiscountAmt = $M.toNum($M.getValue("doc_amt")) - $M.toNum($M.getValue("discount_amt")) - $M.toNum($M.getValue("use_mile_amt"));
				$M.setValue("apply_discount_amt", applyDiscountAmt);
			}
			var vatAmt = $M.toNum($M.getValue("apply_discount_amt"))*0.1;
			$M.setValue("vat_amt", vatAmt);
			var totalAmt = $M.toNum($M.getValue("apply_discount_amt"))+$M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt);
		}

		function fnCalcVat() {
			if($M.toNum($M.getValue("doc_amt")) >= 0){
				var applyDiscountAmt = $M.toNum($M.getValue("doc_amt"))-$M.toNum($M.getValue("discount_amt"))-$M.toNum($M.getValue("use_mile_amt"));
				$M.setValue("apply_discount_amt", applyDiscountAmt);
			}
			var vatAmt = $M.toNum($M.getValue("vat_amt"));
			$M.setValue("vat_amt", vatAmt);
			var totalAmt = $M.toNum($M.getValue("apply_discount_amt"))+$M.toNum($M.getValue("vat_amt"));
			$M.setValue("total_amt", totalAmt);
		}

		function fnClose() {
			window.close();
		}

		// 거래명세서 출력
        function fnTaxBillPrint(bregNameYn) {
			var bregNameYn = bregNameYn == "Y" ? "Y" : "N";
			if ($M.getValue("inout_doc_type_cd") == "05") {
				openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=' + $M.getValue("inout_doc_no")+'&bregNameYn='+bregNameYn);
			} else if ($M.getValue("inout_doc_type_cd") == "07") {
				openReportPanel('serv/serv0101p01_04.crf','inout_doc_no=' + $M.getValue("inout_doc_no")+'&s_job_report_no='+$M.getValue("reference_no")+'&bregNameYn='+bregNameYn);
			} else if ($M.getValue("inout_doc_type_cd") == "11") {
				openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=' + $M.getValue("inout_doc_no")+'&bregNameYn='+bregNameYn);
			} else if ($M.getValue("inout_doc_type_cd") == "08") {
				openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=' + $M.getValue("inout_doc_no")+'&bregNameYn='+bregNameYn);
			}
        }

		// Q&A 10517에 의해 사업제용 출력 추가됨 210325 김상덕
		// 거래명세서 출력 (사업자명)
		function fnTaxBillBregNamePrint() {
			fnTaxBillPrint('Y');
		}

		function goInoutPopup() {
			var popupOption = "";
    		// 입출금전표처리
    		var param = {
    				"cust_no" : $M.getValue("cust_no"),
    				"sale_inout_doc_no" : $M.getValue("inout_doc_no"),
    				"popup_yn" : "Y"
    		};

    		var machineUsedNo = $M.getValue("machine_used_no");
    		var rentalDocNo = $M.getValue("rental_doc_no");
    		var jobReportNo = $M.getValue("job_report_no");
    		var partSaleNo = $M.getValue("part_sale_no");
    		var rentalMachineNo = $M.getValue("rental_machine_no");
    		if(machineUsedNo != ""){
				param.machine_used_no = machineUsedNo;
			} else if(rentalDocNo != ""){
				param.rental_doc_no = rentalDocNo;
			} else if(jobReportNo != ""){
				param.job_report_no = jobReportNo;
			} else if(partSaleNo != ""){
				param.part_sale_no = partSaleNo;
			} else if(rentalMachineNo != ""){
				param.rental_machine_no = rentalMachineNo;
			}

			$M.goNextPage('/cust/cust020301', $M.toGetParam(param), {popupStatus : popupOption});

		}

		// 부품일괄이동요청
		function goTransPart() {
			var params = {
					"invoice_post_no" : $M.getValue("invoice_post_no"),
					"invoice_addr1" : $M.getValue("invoice_addr1"),
					"invoice_addr2" : $M.getValue("invoice_addr2"),
					"invoice_address" : $M.getValue("invoice_addr1") + ' ' + $M.getValue("invoice_addr2"),
					"receive_name" : $M.getValue("receive_name"),
					"receive_tel_no" : $M.getValue("receive_tel_no"),
					"receive_hp_no" : $M.getValue("receive_hp_no"),
					"invoice_qty" : $M.getValue("invoice_qty"),
					"invoice_remark" : $M.getValue("invoice_remark"),
					"invoice_money_cd" : $M.getValue("invoice_money_cd"),
					"invoice_send_cd" : $M.getValue("invoice_send_cd")
			};
			var popupOption = "";

			switch($M.getValue("inout_doc_type_cd")) {
			case "05" : params.search_key = $M.getValue("part_sale_no");
						params.search_type =  "PART_SALE";
				break;
			case "07" : params.search_key = $M.getValue("job_report_no");
						params.search_type = "JOB_REPORT";
				break;
			}

			$M.goNextPage('/comp/comp0606', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 처리센터 변경 시 재고 재조회
	    function fnSetPartQty() {
			if($M.getValue("inout_doc_type_cd") == "05" && inoutYn == "Y") {
				var param = {
						"inout_doc_no" : $M.getValue("inout_doc_no"),
						"inout_org_code" : $M.getValue("inout_org_code")
				}
				$M.goNextPageAjax(this_page + "/searchDtlPartQty", $M.toGetParam(param), {method : 'get'},
					function(result) {
						console.log(result);
				    	if(result.success) {
			    			AUIGrid.setGridData("#auiGrid", result.list);
						}
					}
				);
			}
	    }

		function show() {
			document.getElementById("in_amt_operation").style.display="block";
		}
		function hide() {
			document.getElementById("in_amt_operation").style.display="none";
		}

		// ARS전표 연결팝업
		function goArsInoutDocPopup() {
			var params = {
				"cust_no": $M.getValue("cust_no"),
				"s_start_dt": $M.getValue("inout_dt"),
				"sale_inout_doc_no": $M.getValue("inout_doc_no"),
				"inout_doc_type_cd": "09" // ARS
			};
			$M.goNextPage('/cust/cust0302p03', $M.toGetParam(params), {popupStatus: ""});
		}

        // 부품반품처리
        function goPartReturn() {
			if(partReturnResultCd  ==  "02"){
				alert("이미 반품처리가 완료된 수주입니다.");
				return false;
			}
			var popupOption = "";
			var param = {
				"part_sale_no" : $M.getValue("part_sale_no"),
				"part_return_no" : "${inputParam.part_return_no}",
				"part_return_yn" : "Y",
				"s_popup_yn" : "Y"
			}
			$M.goNextPage('/cust/cust020101', $M.toGetParam(param),  {popupStatus : popupOption});
        }

		// (Q&A 14336) 처리구분 옆에 ? 추가 2022-12-16 김상덕
		function show1() {
			document.getElementById("show1").style.display = "block";
		}

		function hide1() {
			document.getElementById("show1").style.display = "none";
		}

		// 전표분리
		function goInoutDocDiv() {
			var param = {
				"inout_doc_no" : $M.getValue("inout_doc_no")
			};
			var popupOption = "";
			$M.goNextPage('/cust/cust0202p09', $M.toGetParam(param),  {popupStatus : popupOption});
		}
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
	<input type="hidden" name="old_coupon_amt" id="old_coupon_amt"> <!-- 기존쿠폰 사용금액 -->
	<input type="hidden" name="old_mile_amt" id="old_mile_amt"> <!-- 기존마일리지 사용금액 -->
	<input type="hidden" name="send_invoice_seq" id="send_invoice_seq"> <!-- 송장발송번호 -->
	<input type="hidden" name="part_sale_no" id="part_sale_no"><!-- 수주번호 -->
	<input type="hidden" name="job_report_no" id="job_report_no"><!-- 정비번호 -->
	<input type="hidden" name="rental_doc_no" id="rental_doc_no"><!-- 렌탈번호 -->
<input type="hidden" name="machine_doc_no" id="machine_doc_no"><!-- 품의번호 -->
<input type="hidden" name="rental_machine_no" id="rental_machine_no"><!-- 임대장비번호 -->
<input type="hidden" name="add_ut" id="add_ut"><!-- 부가구분(U개별/T합계) -->
<input type="hidden" name="count_breg_no" id="count_breg_no"><!-- 사업자번호 외 몇 건 -->
<input type="hidden" name="check_breg_yn" id="check_breg_yn"><!-- 사업자번호 다수 유무 -->
<input type="hidden" name="cust_no" id="cust_no"><!-- 고객번호 -->
<input type="hidden" name="invoice_type_cd" id="invoice_type_cd">
<input type="hidden" name="invoice_money_cd" id="invoice_money_cd"><!-- 송장비용방식 -->
<input type="hidden" name="invoice_no" id="invoice_no"><!-- 송장번호 -->
<input type="hidden" name="bill_no" id="bill_no"><!-- 대신화물 송장번호 -->
<input type="hidden" name="invoice_qty" id="invoice_qty">
<input type="hidden" name="receive_tel_no" id="receive_tel_no">
<input type="hidden" name="receive_name" id="receive_name">
<input type="hidden" name="receive_hp_no" id="receive_hp_no">
<input type="hidden" name="invoice_remark" id="invoice_remark">
<input type="hidden" name="invoice_post_no" id="invoice_post_no">
<input type="hidden" name="invoice_addr1" id="invoice_addr1">
<input type="hidden" name="invoice_addr2" id="invoice_addr2">
<input type="hidden" name="biz_post_no" id="biz_post_no">
<input type="hidden" name="biz_addr1" id="biz_addr1">
<input type="hidden" name="biz_addr2" id="biz_addr2">
<input type="hidden" name="count_remark" id="count_remark"> <!-- 품명 외 몇 건 -->
<input type="hidden" name="inout_doc_type_cd" id="inout_doc_type_cd" required="required" alt="참조 구분"> <!-- 품의서 구분코드 -->
<input type="hidden" name="item_id_str" id="item_id_str">
<input type="hidden" name="item_name_str" id="item_name_str">
<input type="hidden" name="unit_str" id="unit_str">
<input type="hidden" name="stock_qty_str" id="stock_qty_str">
<input type="hidden" name="qty_str" id="qty_str">
<input type="hidden" name="unit_price_str" id="unit_price_str">
<input type="hidden" name="amt_str" id="amt_str">
<input type="hidden" name="storage_name_str" id="storage_name_str">
<input type="hidden" name="current_all_qty_str" id="current_all_qty_str">
<input type="hidden" name="seq_no_str" id="seq_no_str">
<input type="hidden" name="cust_name_print" id="cust_name_print">
<input type="hidden" name="taxbill_send_cd" id="taxbill_send_cd">
<input type="hidden" name="early_return_yn" id="early_return_yn">
<input type="hidden" name="paper_contents" id="paper_contents" value="">
<input type="hidden" name="paper_send_yn" id="paper_send_yn" value="">
<input type="hidden" name="invoice_send_name" id="invoice_send_name" value="">
<input type="hidden" name="invoice_money_name" id="invoice_money_name"><!-- 송장비용방식 -->
<input type="hidden" name="machine_used_no" id="machine_used_no"><!-- 송장비용방식 -->
<input type="hidden" name="real_breg_no" id="real_breg_no">
<input type="hidden" name="breg_seq" id="breg_seq">
<input type="hidden" name="preorder_yn" id="preorder_yn">
<input type="hidden" name="mul_no" id="mul_no">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
    	    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">
			<div class="btn-group">
	             <div class="right">
	             	<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
	        	</div>
	        </div>
			<div class="row mt5">
<!-- 좌측 폼테이블 -->
				<div class="col-6">
<!-- 전표일자 테이블 -->
					<table class="table-border">
						<colgroup>
							<col width="100px">
							<col width="">
							<col width="100px">
							<col width="">
						</colgroup>
						<tbody>
							<tr>
								<th class="text-right">전표일자</th>
								<td>
									<input type="text" class="form-control width120px sale-rb" id="inout_dt" name="inout_dt" readonly="readonly" dateformat="yyyy-MM-dd" alt="전표일자" required="required">
								</td>
								<th class="text-right">전표번호</th>
								<td>
								<div class="form-row inline-pd">
									<div class="col-7">
										<input type="text" class="form-control width120px" id="inout_doc_no" name="inout_doc_no" readonly="readonly">
									</div>
									<div class="col-5">
									<input type="text" class="form-control width120px" id="mem_name" name="mem_name" readonly="readonly">
									</div>
								</div>
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">처리센터</th>
								<td>
									<div class="input-group width120px">
										<input class="form-control" style="width:99%;" type="text" id="inout_org_code" name="inout_org_code" easyui="combogrid"
										easyuiname="warehouseList" panelwidth="240" idfield="code" textfield="code_name" multi="N" enter="fnSetPartQty();" change="fnSetPartQty();"/>
								</div>
								</td>
								<th class="text-right">물품대</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="doc_amt" name="doc_amt" format="decimal" readonly="readonly">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">쿠폰사용</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right dis_check" id="discount_amt" name="discount_amt" format="decimal" onChange="javascript:fnCalcCoupon();">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
								<th class="text-right">할인적용가</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="apply_discount_amt" name="apply_discount_amt" format="decimal">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">마일리지사용</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="use_mile_amt" name="use_mile_amt" format="decimal" onchange="javascript:fnCalcMile();">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
								<th class="text-right">부가세</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="vat_amt" name="vat_amt" format="decimal" onchange="javascript:fnCalcVat();">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">마일리지적립</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="issued_mile_amt" name="issued_mile_amt" format="decimal" readonly="readonly">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
								<th class="text-right">합계금액</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" readonly="readonly" id="total_amt" name="total_amt" format="decimal">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th></th>
								<td></td>
								<th class="text-right">전표입금액<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show()" onmouseout="javascript:hide()"></i></th>
								<!-- 마우스 오버시 레이어팝업 -->
									<div class="con-info" id="in_amt_operation" style="max-height: 500px; left: 57.5%; width: 180px; display: none; top:40%;">
										<ul class="">
											<ol style="color: #666;">&nbsp;전표에 입출금전표 처리한 금액</ol>
										</ul>
									</div>
								<!-- /마우스 오버시 레이어팝업 -->
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width100px">
											<input type="text" class="form-control text-right" id="in_amt" name="in_amt" format="decimal" disabled="disabled">
										</div>
										<div class="col width33px">원</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">비고</th>
								<td colspan="3">
									<input type="text" class="form-control dis_check" id="desc_text" name="desc_text">
								</td>
							</tr>
							<tr>
								<th class="text-right essential-item">발송구분</th>
								<td colspan="3">
									<div class="form-row inline-pd widthfix mb7">
										<div class="col-3">
											<select class="form-control dis_check sale-rb" required="required" id="invoice_send_cd" name="invoice_send_cd" alt="발송구분" required="required" onChange="javascript:goDeliveryInfo();">
												<option value="">- 선택 -</option>
												<c:forEach items="${codeMap['INVOICE_SEND']}" var="item">
												<option value="${item.code_value}">${item.code_name}</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-4">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_L"/></jsp:include>
										</div>
									<c:if test="${bill_no ne ''}">
										<div class="col-2">
											<input type="text" class="form-control" readonly="readonly" id="arrive_man" name="arrive_man">
										</div>
										<div class="col-3">
											<input type="text" class="form-control" readonly="readonly" id="arrive_man_tel" name="arrive_man_tel">
										</div>
									</c:if>
									</div>
									<div class="form-row inline-pd">
										<div class="col-12">
											<input type="text" class="form-control" readonly="readonly" id="invoice_addr" name="invoice_addr">
										</div>
									</div>
								</td>
							</tr>
							<tr>
								<th class="text-right">최종메모</th>
								<td colspan="3">
									<textarea class="form-control" readonly="readonly" style="height: 166px;" id="last_memo" name="last_memo"></textarea>
								</td>
							</tr>
						</tbody>
					</table>
<!-- /전표일자 테이블 -->
				</div>
<!-- /좌측 폼테이블 -->
<!-- 우측 폼테이블 -->
				<div class="col-6">
<!-- 참조 -->
					<div>
						<div class="title-wrap">
							<h4>참조</h4>
							<div class="end_check dpn" id="end_check"><span class="text-danger">&#91;마감완료&#93;</span> 마감확인전표입니다.</div> <!-- dpn으로 show/hide -->
							<div class="trans_check dpn" id="trans_check"><span class="text-danger">&#91;마감완료&#93;</span> 회계이관전표입니다.</div> <!-- dpn으로 show/hide -->
						</div>

						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">참조번호</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-auto">
												<input type="text" class="form-control" readonly="readonly" id="reference_no" name="reference_no">
											</div>
											<div class="col-auto">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
											</div>
											<div class="left">
												<div class="text-warning ml5" style="font-weight:bold;" id="preorder_inout">
												</div>
											</div>
											<div class="col-auto ml5">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BASE_R"/></jsp:include>
											</div>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /참조 -->
<!-- 고객정보 -->
					<div>
						<div class="title-wrap mt10">
							<h4>고객정보</h4>
						</div>

						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">고객명</th>
									<td>
										<div class="form-row inline-pd pr">
											<div class="col-6">
												<input type="text" class="form-control width120px" id="cust_name" name="cust_name" readonly="readonly" alt="고객명">
											</div>
											<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
				 	                     		<jsp:param name="li_type" value="__ledger#__cust_dtl#__sms_popup#__sms_info#__visit_history#__check_required#__ars_request#__cust_rental_history#__rental_consult_history"/>
					                     	</jsp:include>
										</div>
									</td>
									<th class="text-right">현미수금</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" id="misu_amt" name="misu_amt" readonly="readonly" format="decimal">
											</div>
											<div class="col width33px">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">연락처</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-6">
												<input type="text" class="form-control" id="cust_hp_no" name="cust_hp_no" readonly="readonly">
											</div>
											<div class="col-6">
												<input type="text" class="form-control" id="email" readonly="readonly">
											</div>
										</div>
									</td>
									<th class="text-right">쿠폰잔액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" readonly="readonly" id="coupon_balance_amt" name="coupon_balance_amt" format="decimal">
											</div>
											<div class="col width33px">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">담당자</th>
									<td>
										<input type="text" class="form-control width100px" id="sale_mem_name" name="sale_mem_name" readonly="readonly">
										<input type="hidden" id="sale_mem_no" name="sale_mem_no">
									</td>
									<th class="text-right">누적마일리지</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" id="mile_balance_amt" name="mile_balance_amt" readonly="readonly" format="decimal">
											</div>
											<div class="col width33px">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">입금자</th>
									<td>
										<input type="text" class="form-control width100px" id="deposit_name" name="deposit_name" readonly="readonly">
									</td>
									<th class="text-right">매출한도</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" id="max_misu_amt" name="max_misu_amt" readonly="readonly" format="decimal">
											</div>
											<div class="col width33px">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">입금예정일</th>
									<td colspan="3">
										<input type="text" class="form-control width120px" style="width:120px;" id="deposit_plan_dt" name="deposit_plan_dt" readonly="readonly" dateformat="yyyy-MM-dd">
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /고객정보 -->
<!-- 세금계산서 -->
					<div>
						<div class="title-wrap mt10">
							<h4>세금계산서</h4>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
						</div>
						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th class="text-right essential-item">처리구분
									<i class="material-iconshelp font-16" style="vertical-align: middle;"
									   onmouseover="javascript:show1()" onmouseout="javascript:hide1()"></i>
								</th>
								<div class="con-info" id="show1"
									 style="display: none; max-height: 150px; left: 7%; width: 500px; top:68%;">
									<ul class="">
										<li>
											<span style="font-weight: bold">세금계산서 발행</span><br>
											세금계산서 : 세금계산서 발행<br>
											합산발행 : 계산서 고객 요청에 따라 일괄 합산발행
										</li>
										<li>
											<span style="font-weight: bold">계산서 미발행</span><br>
											카드매출 : 카드로 결제할 경우 선택, 고객이 계산서를 요청하는 경우에는 해당하지 않음.<br>
											현금영수증 : 고객이 계산서 발행없이 현금영수증 끊고자 할때 체크<br>
											무증빙 : 건별처리와 동일, 아무런 증빙을 원하지 않는 경우 처리.
										</li>
									</ul>
								</div>
								<td colspan="3">
									<div class="form-check form-check-inline add-u add-n vatTreatAll vatTreatY">
										<input class="form-check-input vat_treat" type="radio" id="vat_treat_y"
											   name="vat_treat_cd" value="Y" onclick="javascript:fnSearchBregSpec();">
										<label for="vat_treat_y" class="form-check-label">세금계산서</label>
									</div>
									<div class="form-check form-check-inline add-n vatTreatAll vatTreatS">
										<input class="form-check-input vat_treat" type="radio" id="vat_treat_s"
											   name="vat_treat_cd" value="S" onclick="javascript:fnSearchBregSpec();">
										<label for="vat_treat_s" class="form-check-label">합산발행</label>
									</div>
										<div class="form-check form-check-inline add-f add-n ">
											<input class="form-check-input vat_treat" type="radio" id="vat_treat_f" name="vat_treat_cd" value="F">
											<label for="vat_treat_f" class="form-check-label">수정계산서</label>
										</div>
										<span style="font-size:16px" class="add-n">ㅣ&nbsp;&nbsp;&nbsp;</span>
									<%-- (Q&A 14336) 카드/현금/무증빙 파란색으로 - class text-info 추가함. 2022-12-16 김상덕 --%>
									<div class="form-check form-check-inline add-u add-n vatTreatAll vatTreatC">
											<input class="form-check-input vat_treat" type="radio" id="vat_treat_c" name="vat_treat_cd" value="C">
											<label for="vat_treat_c" class="form-check-label text-info">카드매출</label>
									</div>
										<div class="form-check form-check-inline add-u add-n vatTreatAll vatTreatA">
											<input class="form-check-input vat_treat" type="radio" id="vat_treat_a" name="vat_treat_cd" value="A">
											<label for="vat_treat_a" class="form-check-label text-info">현금영수증</label>
									</div>
									<div class="form-check form-check-inline add-u add-n vatTreatAll vatTreatN">
										<input class="form-check-input vat_treat" type="radio" id="vat_treat_n"
											   name="vat_treat_cd" value="N">
										<label for="vat_treat_n" class="form-check-label text-info">무증빙</label>
									</div>
<%--										<div class="form-check form-check-inline add-u add-n vatTreatAll vatTreatR">--%>
<%--											<input class="form-check-input vat_treat" type="radio" id="vat_treat_r" name="vat_treat_cd" value="R">--%>
<%--											<label for="vat_treat_r" class="form-check-label">발행보류(사업자 無)</label>--%>
<%--										</div>--%>
									<span><button type="button" class="btn btn-primary-gra mr10" style="margin-top : -5px;" id="goInoutDocDivBtn" name="goInoutDocDivBtn" onclick="javascript:goInoutDocDiv();">전표분리</button></span>

									</td>
								</tr>
								<tr>
									<th class="text-right">사업자No</th>
									<td colspan="3">
										<div class="form-row inline-pd widthfix">
											<div class="col width160px">
												<input type="hidden" class="form-control" id="breg_no" name="breg_no">
												<input type="text" class="form-control dis_check" id="check_breg_no" name="check_breg_no" readonly="readonly">
											</div>
											<div class="col width80px">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
											</div>
											<div class="col width70px text-right">
												부가세포함
											</div>
											<div class="col width130px">
												<input type="text" class="form-control" readonly="readonly" id="taxbill" name="taxbill">
												<input type="hidden" class="form-control" readonly="readonly" id="taxbill_no" name="taxbill_no">
												<input type="hidden" class="form-control" readonly="readonly" id="acnt_taxbill_no" name="acnt_taxbill_no">
											</div>
											<div class="col width10px">
												-
											</div>
											<div class="col width30px">
												<input type="text" class="form-control" readonly="readonly" id="taxbill_control_no" name="taxbill_control_no">
											</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">업체명</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name">
									</td>
									<th class="text-right">대표자</th>
									<td>
										<input type="text" class="form-control width100px" readonly="readonly" id="breg_rep_name" name="breg_rep_name">
									</td>
								</tr>
								<tr>
									<th class="text-right">업태</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="breg_cor_type" name="breg_cor_type">
									</td>
									<th class="text-right">종목</th>
									<td>
										<input type="text" class="form-control" readonly="readonly" id="breg_cor_part" name="breg_cor_part">
									</td>
								</tr>
								<tr>
									<th class="text-right">주소</th>
									<td colspan="3">
										<input type="text" class="form-control" readonly="readonly" id="biz_addr" name="biz_addr">
									</td>
								</tr>
							<tr>
								<th class="text-right">영수증 상태/용도</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-4">
											<input type="text" class="form-control" id="cash_state" name="cash_state" readonly="readonly">
										</div>
										<div class="col-8">
											<select class="cash form-control" id="tr_code" name="tr_code">
												<option value="0">소득공제용</option>
												<option value="1">지출증빙용</option>
											</select>
										</div>
									</div>
								</td>
								<th class="text-right">이름</th>
								<td>
									<input type="text" class="cash form-control" id="buyr_name" name="buyr_name">
								</td>
							</tr>
							<tr>
								<th class="text-right">휴대폰번호</th>
								<td>
									<input type="text" class="cash form-control" id="id_info" name="id_info">
								</td>
								<th class="text-right">승인번호</th>
								<td>
									<input type="text" class="cash form-control" id="receipt_no" name="receipt_no">
									</td>
								</tr>
							</tbody>
						</table>
					</div>
<!-- /세금계산서 -->
				</div>
<!-- /우측 폼테이블 -->
			</div>
<!-- 하단 폼테이블 -->
			<div>
				<div class="title-wrap mt10">
					<h4>부품목록</h4>
				</div>
				<div id="auiGrid" style="margin-top: 5px; height: 200px;"></div>
			</div>
<!-- /하단 폼테이블 -->
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>
