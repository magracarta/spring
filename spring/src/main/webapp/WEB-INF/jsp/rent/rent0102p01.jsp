<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈운영 > 렌탈장비 출고/회수현황 > null > 렌탈출고/회수처리
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<style>
		.my-row-style {
			background : #CBFFD6;
			color : #000000;
		}
	</style>
	<script type="text/javascript">
		<%-- 여기에 스크립트 넣어주세요. --%>
		var auiGrid;
		var status = '${rent.rental_status_cd}';

		$(document).ready(function() {
			if ("${rent.use_yn}" == "N") {
				alert("삭제된 자료입니다.");
				if (opener != null && opener.goSearch) {
					opener.goSearch();
				}
				fnClose();
			}
			// AUIGrid 생성
			createAUIGridRight();
			fnInit();

			<c:forEach var="outFile" items="${outFileList}">fnPrintFile('${outFile.file_seq}', '${outFile.file_name}', 'out');</c:forEach>
			<c:forEach var="returnFile" items="${returnFileList}">fnPrintFile('${returnFile.file_seq}', '${returnFile.file_name}', 'return');</c:forEach>

			// 배정자 외에는 하단 버튼 노출 X - 2025.01.14 박동훈
			// 종결 , 정산처리 버튼 업무관리자 , 배정자, 서비스관리 (서비스관리에게만 종결취소 버튼 노출) F00967_002
			<%--if("${inputParam.assign_same_yn}" != "Y"){--%>
			<%--	$("#_goCancelRentalConfirm,#_goRentalCancel,#_goExtendPopup,#_goOutRent,#_goReturnEarly,#_goReturn,#_goApprovalEndCancel,#_goApprovalEnd,#_goChangeSave").hide();--%>
			<%--}--%>
			// 2025-02-19 최승희대리는 모든 버튼 노출
			if ("${SecureUser.mem_no}" != "MB00000133") {
				if ("${rental_assign_mem_no}" == "") {
					$("#_goCancelRentalConfirm,#_goRentalCancel,#_goExtendPopup,#_goOutRent,#_goReturnEarly,#_goReturn,#_goApprovalEnd,#_goChangeSave,#_goApprovalEndCancel").hide();
				}else {
					if ("${page.fnc.F00967_002}" != "Y" && "${rental_assign_mem_no}" != "${SecureUser.mem_no}") {
						$("#_goRentalCancel,#_goExtendPopup,#_goExtend,#_goReturnEarly,#_goApprovalEnd,#_goReturn,#_goSale").hide();
					}
					if ("${SecureUser.mem_no}" != "MB00000133") {
						$("#_goApprovalEndCancel").hide();
					}
				}
			}

			// 최승희대리 정산정보수정, 회수시가동시간 수정 버튼노출
			if ("${SecureUser.mem_no}" == "MB00000133") {
				$("#_goChangeSave").show();
			}
		});

		function fnAddFileOut() {
			fnAddFile("out");
		}

		function fnAddFileReturn() {
			fnAddFile("return");
		}

		// 파일추가
		function fnAddFile(type){
			var fileSeqArr = [];
			var fileSeqStr = "";
			$("[name="+type+"_file_seq]").each(function() {
				fileSeqArr.push($(this).val());
			});

			fileSeqStr = $M.getArrStr(fileSeqArr);

			var fileParam = "";
			if("" != fileSeqStr) {
				fileParam = '&file_seq_str='+fileSeqStr;
			}

			openFileUploadMultiPanel('setFileInfo' + type, 'upload_type=RENTAL&file_type=img&total_max_count=0&open_yn=Y'+fileParam);
		}

		function fnPrintFileout(fileSeq, fileName) {
			fnPrintFile(fileSeq, fileName, "out");
		}

		function fnPrintFilereturn(fileSeq, fileName) {
			fnPrintFile(fileSeq, fileName, "return");
		}

		// 첨부파일 출력 (멀티)
		function fnPrintFile(fileSeq, fileName, type) {
			var str = '';
			str += '<div class="table-attfile-item att_' + type + '_file_' + fileSeq + ' '+ type +'fileDiv"style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="' + type + '_file_seq" value="' + fileSeq + '"/>';
			if((type == 'out' && '${rent.out_dt}' == '') || (type == 'return' && '${rent.return_dt}' == '')){
				str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile(' + fileSeq + ', \'' + type + '\')"><i class="material-iconsclose font-18 text-default"></i></button>';
			}

			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.att_' + type + '_file_div').append(str);
		}

		// 첨부파일 삭제
		function fnRemoveFile(fileSeq, type) {
			if (confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.")) {
				$(".att_" + type + "_file_" + fileSeq).remove();
			} else {
				return false;
			}
		}

		function setFileInfoout(result) {
			setFileInfo(result, "out");
		}

		function setFileInforeturn(result) {
			setFileInfo(result, "return");
		}

		// 파일세팅
		function setFileInfo(result, type) {
			$("."+type+"fileDiv").remove(); // 파일영역 초기화

			var fileList = result.fileList;  // 공통 파일업로드(다중) 에서 넘어온 file list
			for (var i = 0; i < fileList.length; i++) {
				fnPrintFile(fileList[i].file_seq, fileList[i].file_name, type);
			}
		}

		function goFileUploadPopupOut() {
			goFileUploadPopup("out");
		}

		function goFileUploadPopupReturn() {
			goFileUploadPopup("return");
		}

		// 점검사항 사진
		// 파일첨부팝업
		function goFileUploadPopup(type) {
			var maxCount = 1;
			var param = {
				upload_type : 'RENTAL',
				file_type : 'img',
				open_yn : 'Y',
			}

			var fileList = [];

			$("[name='" + type + "fileGroup']").each(function () {
				var typeId = $(this).attr("id");

				var tempObj = {};
				tempObj.type_id = typeId;
				tempObj.type_name = $(this).attr("type_name");
				tempObj.max_count = maxCount;
				var fileSeqs = [];
				$(this).find('input').each(function() {
					fileSeqs.push($(this).val());
				})
				tempObj.file_seq_str = $M.getArrStr(fileSeqs);

				fileList.push(tempObj);
			})

			var jsonData = {}
			jsonData.file_list = fileList;

			openFileUploadGroupMultiPanel('fnSetGroupFile'+type, $M.toGetParam(param), jsonData);
		}

		function fnSetGroupFileout(file) {
			fnSetGroupFile(file, "out");
		}

		function fnSetGroupFilereturn(file) {
			fnSetGroupFile(file, "return");
		}

		// 파일세팅
		function fnSetGroupFile(file, type) {
			var fileList = file.list;

			// 기존 파일들 삭제
			$("#" + type + "_file_left").children().remove();
			$("#" + type + "_file_right").children().remove();
			$("#" + type + "_file_btn_div").children().remove();

			var str = '';
			str += '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\'' + type + '\')" id="btn_submit_'+type+'">파일찾기</button>'
			$("#" + type + "_file_btn_div").append(str);

			for (var item in fileList) {
				var typeId = item;

				for (var i = 0; i < fileList[typeId].length; i++) {
					var fileSeq = fileList[typeId][i].file_seq;
					var fileExt = fileList[typeId][i].file_ext;
					var fileName = fileList[typeId][i].file_name;

					var str = '';
					// str += '<div class="table-attfile-item submit_' + typeId + ' typeDiv" id="'+typeId+'">';
					str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
					str += '<input type="hidden" name="'+ typeId +'_seq" value="' + fileSeq + '"  />';
					str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveGroupFile(\'' +  typeId + '\',\''+ type +'\')"><i class="material-iconsclose font-18 text-default"></i></button>';
					// str += '</div>';
					$('#' + typeId).append(str);
				}
			}

			var fileCnt = 0;
			// 좌우 사진이 모두 존재 시 파일찾기 버튼 삭제
			$("[name='" + type + "fileGroup']").each(function (){
				var tagId = $(this).attr('id');

				if (fileList.hasOwnProperty(tagId) != false) {
					fileCnt++;
				}
			});

			if(fileCnt == 2) {
				$("#" + type + "_file_btn_div").children().remove();
			}
		}

		// 파일삭제
		function fnRemoveGroupFile(typeId, type) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$("#" + typeId).children().remove();
				// 파일이 2개여서 파일찾기가 없던 경우에만 추가
				if($M.getValue(type+"_file_left_seq") == "" ^ $M.getValue(type+"_file_right_seq") == "") {
					var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup(\''+type+'\')" id="btn_submit_'+type+'">파일찾기</button>'
					$("#" + type + "_file_btn_div").append(str);
				}
			} else {
				return false;
			}
		}

		function fnCalc() {
			var machine_rental_price = $M.toNum($M.getValue("machine_rental_price"));
			var sumAttachAmt = 0;
			var gridData = AUIGrid.getGridData(auiGrid);
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
			var tempTotalAmt = total_amt;
			var mch_deposit_amt = $M.toNum($M.getValue("mch_deposit_amt"));
			total_amt = total_amt + mch_deposit_amt;
			$M.setValue("rental_amt", total_amt);
			// $M.setValue("vat_rental_amt", Math.floor(total_amt*1.1));
			$M.setValue("vat_rental_amt", Math.floor(tempTotalAmt*1.1) + mch_deposit_amt);
		}

		function goSaleForEarlyReturn() {
			var oldReturnAmt = "${early.return_amt}";
			var returnAmt = $M.getValue("return_amt");

			if (oldReturnAmt != returnAmt) {
				alert("정산정보 수정 후 진행해주세요.");
				return false;
			}

			var amt = $M.toNum(returnAmt) * -1;
			// if(amt > 0) {
			// 	amt = "-" + amt;
			// }

			var param = {
				early_return_yn : "Y",
				rental_doc_no : $M.getValue("rental_doc_no"),
				doc_amt : amt
			}

			openInoutProcPanel("fnReload", $M.toGetParam(param));
		}

		// 조기회수 매출상세
		function goSaleInfoForEarly(callBackMethod) {
			var popupOption = "";
			var param = {
				inout_doc_no : "${rent.inout_doc_no[1]}"
			}
			if (callBackMethod != null) {
				param["parent_js_name"] = callBackMethod;
			}
			$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 매출상세
		function goSaleInfo(callBackMethod) {
			var popupOption = "";
			var param = {
				inout_doc_no : "${rent.inout_doc_no[0]}"
			}
			if (callBackMethod != null) {
				param["parent_js_name"] = callBackMethod;
			}
			$M.goNextPage("/cust/cust0202p01", $M.toGetParam(param), {popupStatus : popupOption});
		}

		// 연장안된 렌탈취소
		function goRentalCancel() {
			// 연장안됐을때
			var callback = "goRentalCancelAfterSaleCancel";
			// 연장되지않고, 마지막자료
			if ("${rent.last_yn}" == "Y") {
				if ("${rent.inout_doc_no[0]}" != "") {
					if (confirm("매출자료를 먼저 삭제해야합니다.\n매출상세로 이동하시겠습니까?") == false) {
						return false;
					}
					goSaleInfo(callback);
				} else {
					// 매출삭제된 자료
					goRentalCancelAfterSaleCancel("");
				}
			} else if ("${rent.last_yn}" == "N") {
				alert("연장된 자료가 있어서 취소할 수 없습니다.\n연장된 자료를 먼저 취소하세요.");
			}
		}

		// 렌탈취소 - 매출처리삭제 콜백(연장 안된 자료)
		function goRentalCancelAfterSaleCancel(row) {
			var param = {
				rental_doc_no : "${rent.rental_doc_no}"
			}
			$M.goNextPageAjax(this_page+"/cancelRental", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							var rentalDocNo = result.rentalDocNo;
							var param = {
								rental_doc_no : rentalDocNo
							}
							var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
							$M.goNextPage(result.goUrl, $M.toGetParam(param), {popupStatus : popupOption});
							fnClose();
						}
					}
			);
		}

		function fnInit() {
			fnChangeDeliveryCd('init');
			var today = "${inputParam.s_end_dt}";
			if($M.getValue("out_dt") == "") {
				$M.setValue("out_dt", today);
			}
			if($M.getValue("return_dt") == "") {
				$M.setValue("return_dt", today);
			}
			if ("${rent.out_dt}" == "") {
				$(".rso").addClass("rs");
				$(".rbo").addClass("rb");
				$("#_goExtendPopup").css("display", "none");
				$("#_goReturn").css("display", "none");
				$("#_goExtend").css("display", "none");
				$("#_goRentalCancel").css("display", "none");
				$(".return_div input").prop("disabled", true);
				$(".return_div select").prop("disabled", true);
			} else {
				$("#_goCancelRentalConfirm").css("display", "none");
				$(".out_div input").prop("disabled", true);
				$("#out_remark").prop("disabled", true);
				$("#out_remark").css("background", "#e9ecef");
				/* $("#rental_delivery_cd").prop("disabled", true); */
				if ("${rent.return_dt}" == "") {
					$(".rsr").addClass("rs");
					$(".rbr").addClass("rb");
				} else {
					$(".return_div input").prop("disabled", true);
					$(".return_div select").prop("disabled", true);
					$("#return_remark").prop("disabled", true);
					$("#return_remark").css("background", "#e9ecef");
				}
			}
			if ("N" == "${rent.last_yn}") {
				$("#_goExtendPopup").css("display", "none");
				$("#_goReturnEarly").css("display", "none");
				$("#_goReturn").css("display", "none");
				$("#_goOutRent").css("display", "none");
				$("#_goExtend").css("display", "none");
				$("#_goRentalCancel").css("display", "none");
				// 종결처리 버튼
				$("#_goApprovalEnd").css("display", "none");
			} else if("${rent.return_dt}" != "") {
				$("#_goExtendPopup").css("display", "none");
				$("#_goReturn").css("display", "none");
				$("#_goOutRent").css("display", "none");
				$("#_goExtend").css("display", "none");
				$("#_goRentalCancel").css("display", "none");
				$(".return_div input").prop("disabled", true);

				if(${not empty early}) {
					$("#_goReturnEarly").css("display", "none");
				}

				if ("${rent.rental_status_cd}" == "05") {
					$("#_goReturnEarly").css("display", "none");
					// 종결처리 버튼
					$("#_goApprovalEnd").css("display", "none");
				}
			} else if("${rent.return_dt}" == "") {
				$("#_goReturnEarly").css("display", "none");
				$("#_goApprovalEnd").css("display", "none");
			}

			// 조기회수가능한 날이 지나면 조기회수 버튼 감춤
			// 조기회수 삭제
			<%--if ("${inputParam.s_current_dt}" >= "${rent.rental_ed_dt}") {--%>
			<%--	$("#_goReturnEarly").css("display", "none");--%>
			<%--}--%>
			// 출고된 자료면 출고버튼 감춤
			if ("${rent.out_dt}" != "") {
				$("#_goOutRent").css("display", "none");
				// $("#_goSavePaperFile").css("display", "none");
				$("#btnAddr").attr("disabled", true);
				$("#delivery_addr2").attr("disabled", true);
			}

			// [재호] [3차-Q&A 15591] 렌탈 신청 상세 수정 추가
			// - 조기회수, 회수 상태일 경우 회수 시 가동시간 수정 할 수 있게 변경
			if("${rent.out_dt}" != "" && "${rent.return_dt}" != "") {
				$("#return_op_hour").attr("disabled", false);
			} else {
				$("#_goChangeSave").remove();
			}

			// 종결취소 버튼 추가
			// 종결상태에서 정산 매출처리가 미진행된경우 종결취소 가능
			if ("${rent.rental_status_cd}" == "05" && ("${early.inout_proc_yn}" == "N" || "${endCancelShowYn}" == "Y")) {
				$("#_goApprovalEndCancel").css("display", false);
			} else {
				$("#_goApprovalEndCancel").css("display", "none");
			}

			<c:if test="${rent.paper_file_seq ne 0}">
			fnPrintPaperFile('${rent.paper_file_seq}','${rent.paper_file_name}');
			$('#paperFileBtn').remove();
			</c:if>
		}

		function fnChangeDeliveryCd(init) {
			$(".two_way_yn").hide();
			var cd = $M.getValue("rental_delivery_cd");
			if (cd == "01") {
				$(".dc *").attr("disabled", true);
				$(".r1s").removeClass("rs");
			} else {
				$(".dc *").attr("disabled", false);
				$(".r1s").addClass("rs");
			}
			if ((cd == "03" || cd == "04") && "${rent.rental_delivery_cd}" != "03" && "${rent.rental_delivery_cd}" != "04" && "${rent.inout_proc_yn}" == "Y") {
				if (cd == "03") {
					$(".two_way_yn").show();
				}
				alert("기매출 자료입니다.\n운임비를 최종렌탈료에 추가할 수 없습니다.\n렌탈취소 후 처리하세요.");
				return false;
			} else {
				$("#transport_amt").prop('disabled', false);
				if (cd == "04") {
					if (init == undefined && ("${rent.rental_delivery_cd}" != "04")) {
						alert("운송사 착불을 유도하고 불가피 할 경우에만 사용 하시고 수주매출로 따로 운송비처리하는 것을 금지합니다.");
					}
				}
				if (cd == "03" || cd == "04") {
					$(".two_way_yn").show();
				}
			}
			if (cd != "03" && cd != "04" && ("${rent.rental_delivery_cd}" == "03" || "${rent.rental_delivery_cd}" == "04") && "${rent.inout_proc_yn}" == "Y") {
				alert("기매출 자료입니다.\n최종렌탈료에서 운임비를 제외할 수 없습니다.\n렌탈취소 후 처리하세요.");
				return false;
			} else {
				$("#transport_amt").prop('disabled', true);
			}
			fnCalc();
		}

		function createAUIGridRight() {
			var gridPros = {
				showRowNumColumn : false,
				rowIdField: "part_no",
				rowStyleFunction : function(rowIndex, item) {
					// 연결된 어태치는 초록색
					if(item.connect_attach_yn == "Y") {
						return "my-row-style";
					}
					return "";
				},
			};

			var columnLayout = [
				{
					headerText : "어태치먼트명",
					dataField : "attach_name",
					width : "200",
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
					formatString : "#,##0"
				},
				{
					headerText : "부품번호",
					dataField : "part_no",
					visible : false,
				},
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
					dataField : "cost_yn",
					visible : false
				},
				{
					dataField : "base_yn",
					visible : false
				},
				{
					dataField : "connect_attach_yn",
					visible : false
				},
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, ${attach});
		}

		function fnReturnValidation() {
			if($M.validation(document.main_form, {field:["return_dt", "return_op_hour", "return_mem_no", "return_job_hour"]}) == false) {
				return false;
			};
			if ($M.getValue("return_gps_op_yn_check") == "") {
				alert("GPS 작동상태를 확인하시기 바랍니다.");
				return false;
			}
			if ($M.getValue("return_dt") < $M.getValue("out_dt")) {
				alert("회수일자가 출고일자 이전일 수 없습니다.");
				$("#return_dt").focus();
				return false;
			}
			// if ($M.getValue("return_dt") < $M.getValue("rental_st_dt")) {
			// 	alert("회수일자가 계약시작일 이전일 수 없습니다.");
			// 	$("#return_dt").focus();
			// 	return false;
			// }

			// (SR : 15591) 회수 사동시간이 더 작아도 수정 가능하게 적용
			if ($M.toNum($M.getValue("out_op_hour")) > $M.toNum($M.getValue("return_op_hour"))) {
				alert("출고 가동시간 보다 회수 가동시간이 작을 수 없습니다.");
				$("#return_op_hour").focus();
				return false;
			}
		}

		function goProcess(control) {
			var param = {
				machine_seq : $M.getValue("machine_seq"),
				rental_doc_no : $M.getValue("rental_doc_no"),
				contract_make_yn : $M.getValue("contract_make_yn_check") == "" ? "N" : "Y",
				id_copy_yn : $M.getValue("id_copy_yn_check") == "" ? "N" : "Y",
				norm_rental_yn : $M.getValue("norm_rental_yn_check") == "" ? "N" : "Y",
				long_rental_yn : $M.getValue("long_rental_yn_check") == "" ? "N" : "Y",
				use_place : $M.getValue("use_place"),
				use_purpose : $M.getValue("use_purpose"),
				remark : $M.getValue("remark"),
				rental_attach_no_str : $M.getArrStr(AUIGrid.getGridData(auiGrid), {key : 'rental_attach_no'}),
			};
			var msg;
			var frm = document.main_form;
			if (control == "O") {
				if (param.contract_make_yn == "N") {
					alert("계약서 작성을 확인하세요");
					return false;
				}
				if($M.validation(frm, {field:["out_dt", "out_op_hour", "rental_delivery_cd", "profit_mem_no_01", "profit_mem_no_02", "profit_mem_no_03"]}) == false) {
					return;
				};
				if ($M.getValue("rental_delivery_cd") != "01" && $M.getValue("rental_delivery_cd") != "") {
					if($M.validation(frm, {field : ["delivery_post_no"]}) == false) {
						return;
					};
				}
				if ($M.getValue("out_gps_op_yn_check") == "") {
					alert("GPS 작동상태를 확인하시기 바랍니다.");
					return false;
				}

				var outFileArr = [];
				$("[name=out_file_seq]").each(function () {
					outFileArr.push($(this).val());
				});

				if(outFileArr.length < 4) {
					alert("출고 시 사진은 최소 4장이 필요합니다.");
					return false;
				}

				if (${empty rent.o_rental_check_name_str}) {
					alert("출고 시 점검사항 확인이 필요합니다.");
					return false;
				}

				<%--if('${rent.left_url}' != '' && '${rent.right_url}' != '') {--%>
				<%--	if($M.getValue("out_file_left_seq") == "" || $M.getValue("out_file_right_seq") == "") {--%>
				<%--		alert("출고 시 점검사항 사진(좌측면, 우측면)이 필요합니다.");--%>
				<%--		return false;--%>
				<%--	}--%>
				<%--}--%>

				if(('${modusignMap.file_seq}' == '' || '${modusignMap.file_seq}' == '0') && $M.getValue("paper_file_seq") == '') {
					alert('전자서명이 완료되거나 종이계약서 업로드 시 출고가 가능합니다.');
					return false;
				}


				var gridData = AUIGrid.getGridData(auiGrid);
				for(var i = 0; i < gridData.length; i++) {
					if(gridData[i].connect_attach_yn == 'N') {
						alert("어테치먼트 관리번호를 등록 후 진행해주세요.");
						return false;
					}
				}

				msg = "출고처리하시겠습니까?";
				param.paper_file_seq = $M.getValue("paper_file_seq");
				param.out_dt = $M.getValue("out_dt");
				param.op_hour = $M.getValue("out_op_hour");
				param.out_gps_op_yn = "Y";
				param.out_job_hour = $M.getValue("out_job_hour");
				param.mode = control;
				param.rental_delivery_cd = $M.getValue("rental_delivery_cd");
				param.delivery_post_no = $M.getValue("delivery_post_no");
				param.delivery_addr1 = $M.getValue("delivery_addr1");
				param.delivery_addr2 = $M.getValue("delivery_addr2");
				param.out_remark = $M.getValue("out_remark");
				param.out_file_left_seq = $M.getValue("out_file_left_seq");
				param.out_file_right_seq = $M.getValue("out_file_right_seq");
				param.out_fuel_qty = $M.getValue("out_fuel_qty");
				param.out_oil_pressure_qty = $M.getValue("out_oil_pressure_qty");
				param.out_engine_oil_qty = $M.getValue("out_engine_oil_qty");

				// 출고 시 사진촬영
				param.out_file_seq_str = $M.getArrStr(outFileArr);

				// 수익배분
				param.profit_mem_no_01 = $M.getValue("profit_mem_no_01");
				param.profit_mem_no_02 = $M.getValue("profit_mem_no_02");
				param.profit_mem_no_03 = $M.getValue("profit_mem_no_03");

				param.profit_rate_01 = $M.getValue("profit_rate_01");
				param.profit_rate_02 = $M.getValue("profit_rate_02");
				param.profit_rate_03 = $M.getValue("profit_rate_03");

				param.rental_profit_share_type_cd_01 = $M.getValue("rental_profit_share_type_cd_01");
				param.rental_profit_share_type_cd_02 = $M.getValue("rental_profit_share_type_cd_02");
				param.rental_profit_share_type_cd_03 = $M.getValue("rental_profit_share_type_cd_03");

			} else if (control == "R") {
				if (fnReturnValidation() == false) {
					return false;
				}
				// 조기회수 삭제
				// if ($M.getValue("return_dt") < $M.getValue("rental_ed_dt")) {
				// 	return confirm("회수예정일("+$M.dateFormat($M.getValue("rental_ed_dt"), "yyyy-MM-dd")+")이 아닙니다. 조기회수하시겠습니까?") == false ? false : goReturnEarlyPopup();
				// } else {
				if ("${rent.out_dt}" == "") {
					alert("출고된 자료가 아닙니다.");
					return false;
				}

				var returnFileArr = [];
				$("[name=return_file_seq]").each(function () {
					returnFileArr.push($(this).val());
				});

				if(returnFileArr.length < 4) {
					alert("회수 시 사진은 최소 4장이 필요합니다.");
					return false;
				}

				if (${empty rent.r_rental_check_name_str}) {
					alert("회수 시 점검사항 확인이 필요합니다.");
					return false;
				}

				<%--if('${rent.left_url}' != '' && '${rent.right_url}' != '') {--%>
				<%--	if ($M.getValue("return_file_left_seq") == "" || $M.getValue("return_file_right_seq") == "") {--%>
				<%--		alert("회수 시 점검사항 사진(좌측면, 우측면)이 필요합니다.");--%>
				<%--		return false;--%>
				<%--	}--%>
				<%--}--%>

				msg = "회수처리하시겠습니까?";
				param.return_dt = $M.getValue("return_dt");
				param.op_hour = $M.getValue("return_op_hour");
				param.return_remark = $M.getValue("return_remark");
				param.return_job_hour = $M.getValue("return_job_hour");
				param.return_mem_no= $M.getValue("return_mem_no");
				param.return_file_left_seq = $M.getValue("return_file_left_seq");
				param.return_file_right_seq = $M.getValue("return_file_right_seq");
				param.return_fuel_qty = $M.getValue("return_fuel_qty");
				param.return_oil_pressure_qty = $M.getValue("return_oil_pressure_qty");
				param.return_engine_oil_qty = $M.getValue("return_engine_oil_qty");
				param.return_gps_op_yn = "Y";
				param.repair_yn = $M.getValue("repair_yn") == "Y" ? "Y" : "N";
				param.repair_remark = $M.getValue("repair_yn") == "Y" ? $M.getValue("repair_remark") : "";

				// 회수 시 사진촬영
				param.return_file_seq_str = $M.getArrStr(returnFileArr);

				param.mode = control;
				// }
			}
			if (confirm(msg) == false) {
				return false;
			}
			$M.goNextPageAjax(this_page, $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
							fnReload();
						}
					}
			);
		}

		function fnClose() {
			window.close();
		}

		function fnReload() {
			location.reload();
		}

		// 조기회수팝업
		// 정산처리로 변경
		// 회수처리 진행 시 모든 팝업은 p02로 이동하므로 정산처리, 종결처리는 여기서 필요없어짐
		function goReturnEarlyPopup() {
			if ("${rent.out_dt}" == "") {
				alert("출고된 자료가 아닙니다.");
				return false;
			}
			if (fnReturnValidation() == false) {
				return false;
			}
			var params = {
				rental_doc_no : $M.getValue("rental_doc_no"),
				rental_st_dt : $M.getValue("rental_st_dt"),
				rental_ed_dt : $M.getValue("rental_ed_dt"),
				rental_amt : $M.toNum($M.getValue("total_rental_amt"))-$M.toNum($M.getValue("discount_amt")),
				rental_attach_no_str : $M.getArrStr(AUIGrid.getGridData(auiGrid), {key : 'rental_attach_no'}),
				use_st_dt : $M.getValue("rental_st_dt"),
				use_ed_dt : $M.getValue("return_dt"),
				op_hour : $M.getValue("return_op_hour"),
				machine_seq : "${rent.machine_seq }",
				rental_machine_no : "${rent.rental_machine_no}",
				out_dt : "${rent.out_dt}",
				return_remark : $M.getValue("return_remark"),
				return_job_hour : $M.getValue("return_job_hour"),
				return_mem_no : $M.getValue("return_mem_no"),
				mch_deposit_amt : $M.getValue("mch_deposit_amt"),
			}
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=600, height=530, left=0, top=0";
			$M.goNextPage('/rent/rent0102p03', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// 렌탈연장팝업
		function goExtendPopup() {
			if ("${rent.out_dt}" == "") {
				alert("출고된 자료가 아닙니다.");
				return false;
			}
			// "1000" 보다 "200"이 크다고 판단해서 숫자로 바꿔서 비교함
// 			if ($M.toNum("${inputParam.s_end_dt}") > $M.toNum($M.getValue("rental_ed_dt"))) {
// 				console.log("${inputParam.s_end_dt}", $M.getValue("rental_ed_dt"));
// 				alert("연장 가능한 날짜가 지났습니다. 렌탈연장은 종료일 이전에만 가능합니다.");
// 				return false;
// 			}
			if (confirm("연장처리화면으로 이동하시겠습니까?") == false) {
				return false;
			};
			var params = {
				/* rental_machine_no : $M.getValue("rental_machine_no"), */
				rental_doc_no : $M.getValue("rental_doc_no"),
				req_extend : "Y"
			}
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
			$M.goNextPage('/rent/rent0102p02', $M.toGetParam(params), {popupStatus : popupOption});
			fnClose();
		}

		// 임대차계약서인쇄
		function goPrint() {
			var params = {
				"rental_doc_no" : '${rent.rental_doc_no}',
				"rental_machine_no" : '${rent.rental_machine_no}'
			}

			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=720, height=250, left=0, top=0";
			$M.goNextPage('/comp/comp1002', $M.toGetParam(params), {popupStatus : popupOption});

			// [재호] [3차-Q&A 15591] 렌탈 신청 상세 수정 추가
			// - 고객명, 회사명 선택 팝업 추가
			<%--openReportPanel('rent/rent0101p01_01.crf','rental_doc_no=' + '${rent.rental_doc_no}'+'&rental_machine_no='+'${rent.rental_machine_no}');--%>

			<%--if(${empty modusignMap.file_seq or modusignMap.file_seq eq '0'}) {--%>
			<%--	alert("모두싸인 문서 서명이 완료되지 않았습니다.\n완료 후 다시 확인해주세요.");--%>
			<%--	return;--%>
			<%--} else {--%>
			<%--	openFileViewerPanel('${modusignMap.file_seq}');--%>
			<%--}--%>
		}

		// 출고처리
		function goOutRent() {
			goProcess("O");
			$M.setValue("mode", "O");
		}

		// 회수처리
		function goReturn() {
			goProcess("R");
			$M.setValue("mode", "R");
		}

		// 조기회수
		function goReturnEarly() {
			goReturnEarlyPopup();
		}

		// 종결처리
		function goApprovalEnd() {
			var param = {
				rental_doc_no : "${rent.rental_doc_no}"
			}
			$M.goNextPageAjaxMsg("종결처리 하시겠습니까?", "/rent/rent0102p02/end", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("정상 처리되었습니다.");
							fnReload();
						}
					}
			);
		}

		// 종결 취소 처리
		function goApprovalEndCancel() {
			var param = {
				rental_doc_no : "${rent.rental_doc_no}"
			}
			$M.goNextPageAjaxMsg("종결취소처리 하시겠습니까?", "/rent/rent0102p02/end/cancel", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("정상 처리되었습니다.");
							fnReload();
						}
					}
			);
		}

		// 조기회수 정보 수정
		function goModify() {
			/* if ("${early.inout_proc_yn}" == "N") {
				alert("매출처리 되지 않은 자료입니다.");
				return false;
			} */
			var param = {
				rental_doc_no : $M.getValue("rental_doc_no"),
				return_amt : $M.getValue("return_amt"),
				return_bank_name : $M.getValue("return_bank_name"),
				return_account_no : $M.getValue("return_account_no"),
				return_deposit_name : $M.getValue("return_deposit_name"),
				remark : $M.getValue("early_remark")
			}
			$M.goNextPageAjax("/rent/rent0102p02/modify/early", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("정상 처리되었습니다.");
							fnReload();
						}
					}
			);
		}

		function fnSetArrival1Addr(row) {
			var param = {
				delivery_post_no: row.zipNo,
				delivery_addr1: row.roadAddr,
				delivery_addr2: row.addrDetail
			};
			$M.setValue(param);
		}

		// 202. 류성진
		// 조기회수 환불 반환요청 쪽지 전송 전, 임시 저장 (계좌정보)
		function goModifyMessage() {
			var param = {
				rental_doc_no : $M.getValue("rental_doc_no"),
				return_account_no : $M.getValue("return_account_no"),
				return_bank_name : $M.getValue("return_bank_name"),
				return_deposit_name : $M.getValue("return_deposit_name"),
			}
			$M.goNextPageAjax("/rent/rent0102p02/modify/early", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							var text = [
								'고객명 : ' + $M.getValue('cust_name'),
								'핸드폰번호 : ' + $M.phoneFormat($M.getValue('hp_no')),
								'은행명 : ' + param.return_bank_name,
								'계좌번호 : ' + param.return_account_no,
								'예금주 : ' + param.return_deposit_name,
								'',
								'환불금액 : '
							].join('#');
							var jsonObject = {
								"paper_contents" : text,
								// "receiver_mem_no_str" : "",	// 수신자
								// "refer_mem_no_str" : "",		// 참조자
								"menu_seq" : "${page.menu_seq}",
								"pop_get_param" : "rental_doc_no=${inputParam.rental_doc_no}",
							}
							openSendPaperPanel(jsonObject);
						}
					}
			);
		}

		// 수익배분
		function fnSetProfit01(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_01", row.mem_no);
			$M.setValue("profit_mem_name_01", row.mem_name);
		}

		function fnSetProfit02(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_02", row.mem_no);
			$M.setValue("profit_mem_name_02", row.mem_name);
		}

		function fnSetProfit03(row) {
			if (row.mem_no == "") {
				alert("올바른 직원을 선택하세요.");
				return false;
			}
			$M.setValue("profit_mem_no_03", row.mem_no);
			$M.setValue("profit_mem_name_03", row.mem_name);
		}

		function goSearchMemberPanel(fn) {
			var param = {
				"agency_yn" : "N"
			}
			openMemberOrgPanel(fn, "N" , $M.toGetParam(param));
		}

		// 업무DB 연결 함수 21-08-06이강원
		function openWorkDB(){
			openWorkDBPanel($M.getValue("machine_seq"), $M.getValue('machine_plant_seq'));
		}

		// [재호] [3차-Q&A 15591] 렌탈 신청 상세 수정 추가
		// 회수 시 가동시간 변경
		function goChangeSave() {
			// (SR : 15591) 회수 사동시간이 더 작아도 수정 가능하게 적용
			// if ($M.toNum($M.getValue("out_op_hour")) > $M.toNum($M.getValue("return_op_hour"))) {
			// 	alert("출고 가동시간 보다 회수 가동시간이 작을 수 없습니다.");
			// 	$("#return_op_hour").focus();
			// 	return false;
			// }

			var param = {
				"rental_doc_no": $M.getValue("rental_doc_no"),
				"return_op_hour" : $M.getValue("return_op_hour"),
				"machine_seq" : $M.getValue("machine_seq"),
				"return_dt" : $M.getValue("return_dt"),
			}

			$M.goNextPageAjaxSave(this_page + '/changeOpHour', $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}

		// [재호] [3차-Q&A 15591] 장비대장 추가
		// 장비 대장 상세
		function goMachineDetail() {
			// 보낼 데이터
			var params = {
				"s_machine_seq" : '${rent.machine_seq}'
			};
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
			$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		// 렌탈이력
		function goRentalHisPopup() {
			var params = {
				machine_name : "${rent.machine_name}",
				body_no : "${rent.body_no}",
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p04', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		//이동이력
		function goMoveHisPopup() {
			var params = {
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/rent/rent0201p05', $M.toGetParam(params), {popupStatus : popupOption});

		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		//수리이력
		function goAsHisPop() {
			var params = {
				s_machine_seq : "${rent.machine_seq}"
			};
			var popupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=430, left=0, top=0";
			$M.goNextPage('/comp/comp0506', $M.toGetParam(params), {popupStatus : popupOption});
		}

		// [재호] [3차-Q&A 15591] 버튼 기능 추가
		// 렌탈장비대장
		function goRentalMachineDetail() {
			var params = {
				rental_machine_no : "${rent.rental_machine_no}"
			};
			var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1200, height=520, left=0, top=0";
			$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
		}

		function fnChangeRepair(event) {
			var target = event.target;
			if(!target)	return;

			var checked = target.checked;
			$M.setValue("repair_yn", checked ? "Y" : "N");

			if(checked) {
				$('.repair-check').removeClass("dpn");
			} else {
				$('.repair-check').addClass("dpn");
			}
		}

		// 모두싸인 요청 (저장 후 진행)
		function sendModusignPanel() {
			if($M.getValue("cust_no") == "") {
				alert("고객선택 후 진행해주세요.");
				return;
			}

			var params = {
				"cust_name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("hp_no"),
				"email" : $M.getValue("email"),
				"breg_name" : $M.getValue("breg_name"),
				"confirm_msg" : "저장된 내용으로 싸인 문서가 발송됩니다.\n내용 변경시 저장 및 싸인취소 후 다시 재진행하셔야 합니다.",
				// "confirm_msg" : "발송 시 저장하지 않은 내용은 계약서에 반영되지 않습니다.\n발송하시겠습니까?",
			}

			openSendModusignPanel('sendModusignAfterSave', $M.toGetParam(params));
		}

		// 모두싸인 대면요청 (저장 후 진행)
		function sendContactModusignPanel() {
			if($M.getValue("cust_no") == "") {
				alert("고객선택 후 진행해주세요.");
				return;
			}

			var params = {
				"cust_name" : $M.getValue("cust_name"),
				"hp_no" : $M.getValue("hp_no"),
				"email" : $M.getValue("email"),
				"breg_name" : $M.getValue("breg_name"),
				"confirm_msg" : "저장된 내용으로 싸인 문서가 발송됩니다.\n내용 변경시 저장 및 싸인취소 후 다시 재진행하셔야 합니다.",
				// "confirm_msg" : "발송 시 저장하지 않은 내용은 계약서에 반영되지 않습니다.\n발송하시겠습니까?",
			}

			openSendContactModusignPanel('sendModusignAfterSave', $M.toGetParam(params));
		}

		function sendModusignAfterSave(data) {

			var param = {
				"cust_breg_name" : data.cust_name,
				"modusign_doc_cd" : 'RENTAL_DOC',
				"modusign_send_cd" : data.modusign_send_cd,
				"send_hp_no" : data.modusign_send_value,
				"hp_no" : data.modusign_send_value,
				"send_email" : data.modusign_send_value,
				"modusign_cust_app_yn" : data.modusign_send_cd == 'SECURE_LINK' ? 'Y' : 'N',
				"rental_doc_no" : $M.getValue("rental_doc_no"),
				"rental_depth" : $M.getValue("rental_depth"),
				"modu_modify_yn" : $M.getValue("modu_modify_yn") == ""? "N":$M.getValue("modu_modify_yn")
			};

			$M.goNextPageAjax("/modu/request_document", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}

		function sendModusignCancel() {
			var msg = "싸인을 취소하시겠습니까?";

			var param = {
				"modusign_id" : "${rent.modusign_id}",
			};

			$M.goNextPageAjaxMsg(msg, "/modu/request/cancel", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							location.reload();
						}
					}
			);
		}

		function fnModusignModify() {
			var frm = document.main_form;

			$("#_sendModusignPanel").show();
			$("#_sendContactModusignPanel").show();
			$("#_fnModusignModify").hide();
			$("#_file_name").hide();
			$M.setValue(frm, "modu_modify_yn", "Y");
		}

		// 첨부파일 출력
		function fnPrintPaperFile(fileSeq, fileName) {
			var str = '';
			str += '<div class="table-attfile-item paper_file" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + fileSeq + ');" style="color: blue; vertical-align: middle;">' + fileName + '</a>&nbsp;';
			str += '<input type="hidden" name="paper_file_seq" value="' + fileSeq + '"/>';
			str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile()"><i class="material-iconsclose font-16 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.paper_file_div').append(str);
		}

		// 첨부파일 버튼 클릭
		function fnAddPaperFile(){
			if($M.getValue("paper_file_seq") != "0" && $M.getValue("paper_file_seq") != "") {
				alert("파일은 1개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setPaperFileInfo', 'upload_type=RENT&file_type=img&max_size=10240');
		}

		function setPaperFileInfo(result) {
			fnPrintPaperFile(result.file_seq, result.file_name);
			$('#paperFileBtn').remove();
		}

		// 첨부파일 삭제
		function fnRemoveFile() {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".paper_file").remove();
				$(".paper_file_td").append('<button type="button" class="btn btn-primary-gra" id="paperFileBtn" onclick="javascript:fnAddPaperFile()" >파일찾기</button>');
			} else {
				return false;
			}
		}

		// 어태치먼트 연결
		function goAttachConnect() {
			var param = {
				"s_rental_doc_no" : $M.getValue("rental_doc_no"),
				"s_mng_org_code" : '${rent.mng_org_code}',
				"s_type_or" : ${not empty rent.out_dt} ? 'R' : 'O',
				"s_connect_yn" : ${empty rent.out_dt} ? 'N' : 'Y',
			}

			openConnectRentalDocAttach('fnConnectAttach', $M.toGetParam(param));
		}

		function fnConnectAttach(partNo) {
			var item = {
				part_no : partNo,
				connect_attach_yn : "Y"
			}

			AUIGrid.updateRowsById(auiGrid, item);
			AUIGrid.update(auiGrid);
		}

		function goCancelRentalConfirm() {
			var param = {
				"inout_doc_no" : "${rent.inout_doc_no[0]}"
			}

			var msg = "출고요청을 취소하시겠습니까?\n취소 시 렌탈확정 상태인 문서가 작성중으로 변경됩니다.";

			$M.goNextPageAjaxMsg(msg, this_page + '/cancel/confirm', $M.toGetParam(param) , {method : 'POST'},
					function(result) {
						if(result.success) {

							if(result.end_yn == "Y") {
								alert("매출전표가 마감처리되어 출고요청을 취소할 수 없습니다.\n마감취소 후 다시 시도해주세요.");
								return;
							} else if(result.duzon_trans_yn == "Y") {
								alert("매출전표가 회계전송이 완료되어 출고요청을 취소할 수 없습니다.");
								return;
							} else if(result.report_yn == "Y") {
								alert("매출전표 세금계산서가 신고되어 출고요청을 취소할 수 없습니다.");
								return;
							} else {
								var param = {
									"inout_doc_no": result.inout_doc_no,
									"cust_no": result.cust_no,
									"send_invoice_seq": result.send_invoice_seq,
									"inout_doc_type_cd": result.inout_doc_type_cd,
								}

								$M.goNextPageAjax('/cust/cust0202p01/remove', $M.toGetParam(param), {
											method: 'POST',
											timeout: 60 * 60 * 1000
										},
										function (result) {
											if (result.success) {
												alert("출고요청 취소가 완료되었습니다.");
												var param = {
													rental_doc_no : $M.getValue("rental_doc_no")
												}
												var popupOption = "scrollbars=no, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
												$M.goNextPage("/rent/rent0101p01", $M.toGetParam(param), {popupStatus : popupOption});
												fnClose();
											}
										}
								);
							}

						}
				});
		}

		function goSavePaperFile() {
			if($M.getValue("paper_file_seq") == "") {
				alert("종이계약서 추가 후 다시 시도해주세요.");
				return;
			}

			var param = {
				"rental_doc_no" : $M.getValue("rental_doc_no"),
				"paper_file_seq" : $M.getValue("paper_file_seq"),
				"pre_paper_file_seq" : $M.getValue("pre_paper_file_seq"),
			}

			$M.goNextPageAjaxMsg("종이계약서를 저장하시겠습니까?", this_page + "/paper/save", $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("처리가 완료되었습니다.");
						}
					}
			);
		}
	</script>
</head>
<body   class="bg-white" >
<form id="main_form" name="main_form">
	<input type="hidden" name="mode">
	<input type="hidden" name="contract_make_yn">
	<input type="hidden" name="id_copy_yn">
	<input type="hidden" name="norm_rental_yn">
	<input type="hidden" name="long_rental_yn">
	<input type="hidden" name="rental_machine_no" value="${rent.rental_machine_no}">
	<input type="hidden" name="rental_doc_no" value="${rent.rental_doc_no }">
	<input type="hidden" name="up_rental_doc_no" value="${rent.up_rental_doc_no }">
	<input type="hidden" name="machine_seq" value="${rent.machine_seq }">
	<input type="hidden" name="machine_plant_seq" value="${rent.machine_plant_seq}">
	<input type="hidden" name="pre_paper_file_seq" value="${rent.pre_paper_file_seq }">
	<input type="hidden" name="rental_depth" value="${rent.rental_depth }">
	<input type="hidden" name="modu_modify_yn" value="${modusignMap.modu_modify_yn}">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per" style="min-width: 1385px;">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<div class="row">
				<div class="col-6">
					<!-- 장비정보 -->
					<div class="title-wrap approval-left">
						<h4>장비정보</h4>
						<div class="right">
							<span class="condition-item">상태 :
								<c:choose>
									<c:when test="${empty rent.out_dt }">출고요청</c:when>
									<c:otherwise>
										<c:choose>
											<c:when test="${empty rent.return_dt }">출고</c:when>
											<c:otherwise>
												<c:choose>
													<c:when test="${rent.rental_status_cd ne '05'}">미정산</c:when>
													<c:otherwise>종결</c:otherwise>
												</c:choose>
											</c:otherwise>
										</c:choose>
									</c:otherwise>
								</c:choose>
							</span>
							<span class="condition-item">신청 :
								<c:choose>
									<c:when test="${empty rent.c_rental_request_seq }">ERP</c:when>
									<c:otherwise>고객앱</c:otherwise>
								</c:choose>
							</span>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">메이커</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" value="${rent.maker_name}">
							</td>
							<th class="text-right">모델</th>
							<td>
								<div class="form-row inline-pd pr">
									<div class="col-auto">
										<input type="text" class="form-control width120px" readonly="readonly" value="${rent.machine_name}">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">연식</th>
							<td>
								<input type="text" class="form-control width60px" readonly="readonly" value="${fn:substring(rent.made_dt,0,4)}">
							</td>
							<th class="text-right">가동시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width60px">
										<input type="text" class="form-control" readonly="readonly" value="${rent.op_hour }" id="a" name="a" format="decimal">
									</div>
									<div class="col width22px">hr</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">차대번호</th>
							<td>
								<div style="display: flex">
									<input type="text" class="form-control width180px" style="margin-right: 10px" readonly="readonly" value="${rent.body_no }">
									<button type="button" class="btn btn-primary-gra mr5" onclick="javascript:openWorkDB();">업무DB</button>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
								</div>
							</td>
							<th class="text-right">번호판번호</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mreg_no }">
							</td>
						</tr>
						<tr>
							<th class="text-right">GPS</th>
							<td>
								<c:choose>
									<c:when test="${not empty rent.sar }">
										<span class="underline" onclick="javascript:window.open('https://terra.smartassist.yanmar.com/machine-operation/map')">SA-R</span>
									</c:when>
									<c:otherwise>
										<input type="hidden" id="gps_seq" name="gps_seq" value="${rent.gps_seq}" >
										<div class="form-row inline-pd widthfix">
											<div class="col width33px text-right">
												종류
											</div>
											<div class="col width80px">
												<select class="form-control" id="gps_type_cd" name="gps_type_cd" disabled="disabled">
													<option value="">- 선택 -</option>
													<c:forEach items="${codeMap['GPS_TYPE']}" var="codeitem">
														<option value="${codeitem.code_value}" ${rent.gps_type_cd eq codeitem.code_value ? 'selected="selected"' : ''}>${codeitem.code_name}</option>
													</c:forEach>
												</select>
											</div>
											<div class="col width55px text-right">
												개통번호
											</div>
											<div class="col width100px">
												<input type="text" class="form-control underline" readonly="readonly" id="gps_no" name="gps_no" value="${rent.gps_no}" onclick="javascript:window.open('http://s1.u-vis.com')">
											</div>
										</div>
									</c:otherwise>
								</c:choose>
							</td>
							<th class="text-right">관리센터</th>
							<td>
								<input type="text" class="form-control width120px" readonly="readonly" value="${rent.mng_org_name }">
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /장비정보 -->
				</div>
				<div class="col-6">
					<!-- 고객정보 -->
					<div class="title-wrap">
						<h4>고객정보</h4>
						<div class="right mt-5">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_M"/></jsp:include>
							<button type="button" class="btn btn-md btn-rounded btn-outline-primary"  onclick="javascript:goPrint();" ><i class="material-iconsprint text-primary"></i> 임대차계약서인쇄</button>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="140px">
							<col width="100px">
							<col width="120px">
							<col width="100px">
							<col width="120px">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">고객명/휴대전화</th>
							<td colspan="2">
								<div class="form-row inline-pd">
									<div class="col-4">
											<input type="text" class="form-control" id="cust_name" name="cust_name" readonly="readonly" required="required" alt="고객명" value="${rent.cust_name }">
											<input type="hidden" id="cust_no" name="cust_no" value="${rent.cust_no }">
											<!-- 연관업무 버튼 마우`스 오버시 레이어팝업 -->
											<input type="hidden" name="__s_cust_no" value="${rent.cust_no}">
											<input type="hidden" name="__s_hp_no" value="${rent.hp_no}">
											<input type="hidden" name="__s_cust_name" value="${rent.cust_name}">
											<!-- /연관업무 버튼 마우스 오버시 레이어팝업 -->
									</div>
									<div class="col-3">
											<jsp:include page="/WEB-INF/jsp/common/commonCustJob.jsp">
												<jsp:param name="li_type" value="__ledger#__sms_popup#__sms_info#__check_required#__cust_rental_history#__rental_consult_history"/>
											</jsp:include>
									</div>
									</div>
									<div class="col-4">
										<input type="text" class="form-control width120px" readonly="readonly" id="hp_no" name="hp_no" value="${rent.hp_no }" format="tel">
									</div>
								</div>
							</td>
							<th class="text-right">업체명/사업자번호</th>
							<td colspan="2">
								<div class="row">
									<div class="col-6">
										<input type="text" class="form-control" readonly="readonly" id="breg_name" name="breg_name" value="${rent.breg_name }">
									</div>
									<div class="col-6">
										<input type="text" class="form-control" readonly="readonly" id="breg_no" name="breg_no" value="${rent.breg_no }" format="bregno">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">주소</th>
							<td colspan="5">
								<div class="row">
									<div class="col-6">
										<input type="text" class="form-control" readonly="readonly" id="addr1" name="addr1" value="${rent.addr1 }">
									</div>
									<div class="col-6">
										<input type="text" class="form-control" readonly="readonly" id="addr2" name="addr2" value="${rent.addr2 }">
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">사업자등록구분</th>
							<td>
								<div id="breg_type_name">
									${rent.breg_type_name}
								</div>
							</td>
							<th class="text-right">장비보유여부</th>
							<td>
								<div class="row" style="margin-left:1px;">
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="machine_has_yn_y" name="machine_has_yn" value="Y" <c:if test="${rent.machine_has_yn == 'Y'}">checked="checked"</c:if> disabled>
										<label class="form-check-label" for="machine_has_yn_y">보유</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="radio" id="machine_has_yn_n" name="machine_has_yn" value="N" <c:if test="${rent.machine_has_yn == 'N'}">checked="checked"</c:if> disabled>
										<label class="form-check-label" for="machine_has_yn_n">미보유</label>
									</div>
								</div>
							</td>
							<th class="text-right" rowspan="2">계약일수</th>
							<td rowspan="2">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="day_cnt_under_7" name="rental_day_check" value="A" <c:if test="${rent.rental_day_check == 'A'}">checked="checked"</c:if> disabled>
									<label class="form-check-label" for="day_cnt_under_7">7일 이하</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="day_cnt_under_31" name="rental_day_check" value="B" <c:if test="${rent.rental_day_check == 'B'}">checked="checked"</c:if> disabled>
									<label class="form-check-label" for="day_cnt_under_31">8~31일</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" id="day_cnt_over_31" name="rental_day_check" value="C" <c:if test="${rent.rental_day_check == 'C'}">checked="checked"</c:if> disabled>
									<label class="form-check-label" for="day_cnt_over_31">32일 이상</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">당년 렌탈이력</th>
							<td>
								<div class="row">
									<div class="col-6">
										<input type="text" class="form-control" readonly="readonly" id="year_rental_cnt" name="year_rental_cnt" value="${rent.year_rental_cnt}">
									</div>
									회
								</div>
							</td>
							<th class="text-right">총 렌탈이력</th>
							<td>
								<div class="row">
									<div class="col-6">
										<input type="text" class="form-control" readonly="readonly" id="total_rental_cnt" name="total_rental_cnt" value="${rent.total_rental_cnt}">
									</div>
									회
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /고객정보 -->
				</div>
			</div>
			<div class="row mt10">
				<div class="col-6">
					<!-- 렌탈정보 -->
					<div class="title-wrap approval-left">
						<div class="left">
							<h4>렌탈정보</h4>
							<div class="right text-warning ml5">
								1일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_1_price}" />&nbsp;&nbsp;
								7일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_7_price}" />&nbsp;&nbsp;
								15일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_15_price}" />&nbsp;&nbsp;
								30일:<fmt:formatNumber type="number" maxFractionDigits="3" value="${rent.day_30_price}" />
							</div>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">관리번호</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width120px">
										<input type="text" class="form-control" readonly="readonly" value="${rent.rental_doc_no}">
									</div>
									<c:choose>
										<c:when test="${empty rent.inout_proc_yn or rent.inout_proc_yn ne 'Y'}">
											<span style="color: red">매출처리 안된 자료</span>
										</c:when>
										<c:otherwise>
											<button type="button" onclick="goSaleInfo()" class="btn btn-default">매출상세</button>
										</c:otherwise>
									</c:choose>
								</div>
							</td>
							<th class="text-right">담당자</th>
							<td colspan="3">
								<input type="text" class="form-control width100px" readonly="readonly" value="${rent.receipt_mem_name }">
							</td>
						</tr>
						<tr>
							<th class="text-right rs">렌탈기간</th>
							<td colspan="7">
								<div class="form-row inline-pd widthfix">
									<div class="col width110px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="rental_st_dt" name="rental_st_dt" dateFormat="yyyy-MM-dd" alt="렌탈 시작일" value="${rent.rental_st_dt }" onchange="fnSetDayCnt()" required="required" disabled="disabled">
										</div>
									</div>
									<div class="col width16px text-center">~</div>
									<div class="col width120px">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="rental_ed_dt" name="rental_ed_dt" dateFormat="yyyy-MM-dd" alt="렌탈 종료일" value="${rent.rental_ed_dt }" onchange="fnSetDayCnt()" required="required" disabled="disabled">
										</div>
									</div>
									<div class="col width50px text-right">
										<input type="text" class="form-control" readonly="readonly" id="day_cnt" name="day_cnt" value="${rent.day_cnt}" format="decimal">
									</div>
									<div class="col width16px">
										일
									</div>
								</div>
							</td>
						</tr>
						<tr class="out_div">
							<th class="text-right rs">인도방법</th>
							<td colspan="3">
								<select class="form-control width130px rb inline" id="rental_delivery_cd" name="rental_delivery_cd" alt="인도방법" onchange="javascript:fnChangeDeliveryCd()" required="required" <c:if test="${not empty rent.out_dt}">disabled="disabled"</c:if>>
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
							<th class="text-right">서류</th>
							<td colspan="3">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" name="contract_make_yn_check" id="contract_make_yn_check" value="Y" <c:if test="${rent.contract_make_yn == 'Y'}">checked="checked"</c:if>>
									<label class="form-check-label" for="contract_make_yn_check" ${rent.contract_make_yn != 'Y' ? 'style="color : red;"' : ''}>계약서작성</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" name="id_copy_yn_check" id="id_copy_yn_check" value="Y" <c:if test="${rent.id_copy_yn == 'Y'}">checked="checked"</c:if>>
									<label class="form-check-label" for="id_copy_yn_check">신분증사본</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right r1s">배송지</th>
							<td colspan="7">
								<div class="form-row inline-pd dc">
									<div class="col-1 pdr0">
										<input type="text" class="form-control mw45" readonly="readonly"
											   id="delivery_post_no" name="delivery_post_no" alt="배송지우편번호"
											   value="${rent.delivery_post_no}" required="required">
									</div>
									<div class="col-auto pdl5">
										<button type="button" class="btn btn-primary-gra full"
												onclick="javascript:openSearchAddrPanel('fnSetArrival1Addr');" <c:if test="${not empty rent.out_dt}">disabled="disabled"</c:if>>주소찾기
										</button>
									</div>
									<div class="col-5">
										<input type="text" class="form-control" readonly="readonly"
											   id="delivery_addr1" name="delivery_addr1"
											   value="${rent.delivery_addr1}" required="required">
									</div>
									<div class="col-4">
										<input type="text" class="form-control" id="delivery_addr2"
											   name="delivery_addr2" value="${rent.delivery_addr2}" <c:if test="${not empty rent.out_dt}">disabled="disabled"</c:if>>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">사용장소</th>
							<td colspan="3">
								<div>
									<select class="form-control width130px rb inline" id="sale_area_code" name="sale_area_code" alt="실 사용지역" readonly="readonly">
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
									<select class="form-control rb" id="mch_use_cd" name="mch_use_cd" alt="장비용도" readonly="readonly">
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
									<input type="text" class="form-control" maxlength="50" alt="" id="use_purpose" name="use_purpose" value="${rent.use_purpose }" <c:if test="${not empty rent.out_dt}">disabled="disabled"</c:if>>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">임차구분</th>
							<td colspan="3">
								<div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="norm_rental_yn_check" name="norm_rental_yn_check" value="Y" <c:if test="${rent.norm_rental_yn == 'Y'}">checked="checked"</c:if> <c:if test="${not empty rent.out_dt}">disabled="disabled"</c:if>>
										<label class="form-check-label" for="norm_rental_yn_check">일반</label>
									</div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="long_rental_yn_check" name="long_rental_yn_check" value="Y" <c:if test="${rent.long_rental_yn == 'Y'}">checked="checked"</c:if> <c:if test="${not empty rent.out_dt}">disabled="disabled"</c:if>>
										<label class="form-check-label" for="long_rental_yn_check">장기</label>
									</div>
								</div>
							</td>
							<th class="text-right">렌탈계산식</th>
							<td style="font-size: 11px" colspan="3">최종렌탈료=A+B-C+D (직배송 또는 선결제일 경우에만 D 합산)</td>
							<%-- <th class="text-right">운임비</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" format="decimal" value="${rent.transport_amt}" <c:if test="${not empty rent.out_dt or (rent.rental_delivery_cd eq '03' and rent.inout_proc_yn eq 'Y') or (rent.rental_delivery_cd eq '04' and rent.inout_proc_yn eq 'Y')}">disabled="disabled"</c:if> onchange="javascript:fnCalc()">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>
                            </td> --%>
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
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="attach_rental_price" name="attach_rental_price" format="decimal" value="${rent.attach_rental_price}">
									</div>
									<div class="col width16px">원</div>
									(B)
								</div>
							</td>
							<th class="text-right">장비보증금</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="mch_deposit_amt" name="mch_deposit_amt" format="minusNum" onchange="javascript:fnCalc()" value="${rent.mch_deposit_amt}">
									</div>
									<div class="col width16px">원</div>
								</div>
							</td>
						</tr>
						<tr>
							<%-- <th class="text-right">어태치렌탈료</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" readonly="readonly" id="attach_rental_price" name="attach_rental_price" format="decimal" value="${rent.attach_rental_price}">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>
                            </td> --%>
							<th class="text-right">총렌탈료</th>
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
										<input type="text" class="form-control text-right" readonly="readonly" id="discount_amt" name="discount_amt" format="minusNum" value="${rent.discount_amt}">
									</div>
									<div class="col width16px">원</div>
									(C) 양수=할인, 음수=할증
								</div>
							</td>
						</tr>
						<tr>
							<%-- <th class="text-right">렌탈료조정</th>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col width100px">
                                        <input type="text" class="form-control text-right" readonly="readonly" id="discount_amt" name="discount_amt" format="minusNum" value="${rent.discount_amt}">
                                    </div>
                                    <div class="col width16px">원</div>
                                </div>
                            </td> --%>
							<th class="text-right">운임비</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" id="transport_amt" name="transport_amt" format="decimal" value="${rent.transport_amt}" <c:if test="${not empty rent.out_dt or (rent.rental_delivery_cd eq '03' and rent.inout_proc_yn eq 'Y') or (rent.rental_delivery_cd eq '04' and rent.inout_proc_yn eq 'Y')}">disabled="disabled"</c:if> onchange="javascript:fnCalc()">
									</div>
									<div class="col width16px">원</div>
									<span style="color: red">(D) 직배송,선결제시 최종렌탈료에 합산</span>
								</div>
							</td>
							<th class="text-right">
								<div>최종렌탈료</div>
							</th>
							<td colspan="3">
								<div class="form-row inline-pd widthfix">
									<div class="col width100px">
										<input type="text" class="form-control text-right" readonly="readonly" id="rental_amt" name="rental_amt" format="decimal" value="${rent.rental_amt}">
									</div>
									<div class="col width16px">원</div>
									<div style="margin-left: 5px;">VAT포함 :<div style="display: inline-block;"><input class="form-control" type="text" id="vat_rental_amt" name="vat_rental_amt" format="decimal" readonly="readonly" value="${rent.vat_rental_amt}"></div></div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right">계약 시 특이사항</th>
							<td colspan="3">
								<textarea class="form-control" style="height: 100%; min-height: 70px" id="remark" name="remark" maxlength="300">${rent.remark }</textarea>
							</td>
							<c:if test="${not empty shareList }"> <!-- 상세부터는 테이블에 저장된 정보를 사용함, 코드 사용안함!(코드가 중간에 변경될수도있음) -->
								<th class="text-right">수익배분</th>
								<td colspan="3">
									<table style="border-collapse: collapse;">
										<colgroup>
											<col width="33.33%">
											<col width="33.33%">
											<col width="33.33%">
										</colgroup>
										<c:forEach items="${shareList}" var="item">
											<tr>
												<td>
													<c:if test="${item.rental_profit_share_type_cd eq '02'}">
														<div style="display: inline-block;">${item.kor_name} (${item.profit_rate }%)</div>
													</c:if>
													<c:if test="${item.rental_profit_share_type_cd ne '02'}">
														<div style="display: inline-block;">${item.rental_profit_share_type_name} (${item.profit_rate }%)</div>
													</c:if>
													<input type="hidden" name="rental_profit_share_type_cd_${item.rental_profit_share_type_cd}" value="${item.rental_profit_share_type_cd}">
													<input type="hidden" name="profit_rate_${item.rental_profit_share_type_cd}" value="${item.profit_rate}">
												</td>
												<td>
													<fmt:formatNumber type="number" maxFractionDigits="3" value="${item.profit_amt}" />
												</td>
												<td>
														<%-- <select class="form-control rb" id="profit_mem_no_${item.rental_profit_share_type_cd}" name="profit_mem_no_${item.rental_profit_share_type_cd}" alt="${item.rental_profit_share_type_name }" ${not empty rent.out_dt ? 'disabled' : ''}>
                                                            <option value="">- 선택 - </option>
                                                            <c:forEach items="${centerMemList}" var="innerItem">
                                                                <option value="${innerItem.mem_no }" ${item.mem_no eq innerItem.mem_no ? 'selected' : ''}>${innerItem.mem_name }</option>
                                                            </c:forEach>
                                                        </select> --%>
													<div class="input-group">
<%--														<select class="form-control width130px rb inline" id="profit_org_code_${item.code_value}" name="profit_org_code_${item.code_value}" required="required" alt="${item.code_name}" ${not empty rent.out_dt ? 'disabled' : ''}>--%>
<%--															<option value="">- 선택 -</option>--%>
<%--															<c:forEach items="${orgCenterList}" var="listItem">--%>
<%--																<option value="${listItem.org_code}" <c:if test="${listItem.org_code eq item.org_code}">selected="selected"</c:if>>${listItem.org_name}</option>--%>
<%--															</c:forEach>--%>
<%--														</select>--%>
														<input type="text" class="form-control border-right-0" id="profit_mem_name_${item.rental_profit_share_type_cd}" name="profit_mem_name_${item.rental_profit_share_type_cd}" placeholder="직원을조회하세요" value="${item.mem_name}" readonly="readonly" style="background: white" alt="${item.rental_profit_share_type_name}">
														<input type="hidden" id="profit_mem_no_${item.rental_profit_share_type_cd}" name="profit_mem_no_${item.rental_profit_share_type_cd}" value="${item.mem_no}" required="required" alt="${item.rental_profit_share_type_name}">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goSearchMemberPanel('fnSetProfit${item.rental_profit_share_type_cd}')" ${not empty rent.out_dt ? 'disabled' : ''}><i class="material-iconssearch"></i></button>
													</div>
												</td>
											</tr>
										</c:forEach>
									</table>
								</td>
								<%-- <td class="">
                                    <table style="border-collapse: collapse; border: none;">
                                       <c:forEach items="${shareList}" var="item">
                                          <tr>
                                             <td>
                                                <div style="display: inline-block;">${item.rental_profit_share_type_name} (${item.profit_rate }%)</div>
                                                <input type="hidden" name="rental_profit_share_type_cd_${item.rental_profit_share_type_cd}" value="${item.rental_profit_share_type_cd}">
                                                <input type="hidden" name="profit_rate_${item.rental_profit_share_type_cd}" value="${item.profit_rate}">
                                             </td>
                                             <td>
                                                 <fmt:formatNumber type="number" maxFractionDigits="3" value="${item.profit_amt}" />
                                             </td>
                                             <td>
                                                 <div id="profit_mem_name_${item.rental_profit_share_type_cd}">${item.mem_name }</div>
                                                 <input type="hidden" id="profit_mem_no_${item.rental_profit_share_type_cd}" name="profit_mem_no_${item.rental_profit_share_type_cd}" value="${item.mem_no}">
                                             </td>
                                             <td>
                                                <div style="display: inline-block;">
                                                   <button type="button" class="btn btn-default" onclick="javascript:openMemberOrgPanel('fnSetProfit${item.rental_profit_share_type_cd}', 'N')"><i class="material-iconsadd text-default"></i>직원변경</button>
                                                </div>
                                             </td>
                                          </tr>
                                       </c:forEach>
                                    </table>
                                </td> --%>
							</c:if>
						</tr>
						</tbody>
					</table>
					<!-- /렌탈정보 -->
				</div>
				<div class="col-6">
					<!-- 어태치먼트 -->
					<div class="title-wrap">
						<h4>어태치먼트</h4>
						<!-- <button type="button" class="btn btn-default"  onclick="javascript:go2();" ><i class="material-iconsadd text-default"></i>어태치먼트추가</button> -->
<%--						<div style="display: flex;">--%>
<%--							<div style="line-height: 2; margin-right: 5px">[기본수량]</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 대</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="big_bucket_cnt" name="big_bucket_cnt" alt="대버켓 숫자" value="${rent.big_bucket_cnt}" datatype="int" disabled="disabled">--%>
<%--							</div>--%>
<%--							<div class="vl">|</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 중</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="mid_bucket_cnt" name="mid_bucket_cnt" alt="중버켓 숫자" value="${rent.mid_bucket_cnt}" datatype="int" disabled="disabled">--%>
<%--							</div>--%>
<%--							<div class="vl">|</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 소</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="sml_bucket_cnt" name="sml_bucket_cnt" alt="소버켓 숫자" value="${rent.sml_bucket_cnt}" datatype="int" disabled="disabled">--%>
<%--							</div>--%>
<%--							<div class="vl">|</div>--%>
<%--							<div>--%>
<%--								<span style="margin-right: 3px; line-height: 2"> 키</span>--%>
<%--								<input type="text" class="form-control width24px cInput" id="key_cnt" name="key_cnt" alt="키 숫자" value="${rent.key_cnt}" datatype="int" disabled="disabled">--%>
<%--							</div>--%>
<%--						</div>--%>
<%--						<div></div>--%>
						<c:if test="${empty rent.return_dt}">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
						</c:if>
					</div>
					<div style="margin-top: 5px; height: 150px;"  id="auiGrid"  ></div>
					<!-- 계약정보 -->
					<div class="title-wrap mt5">
						<h4>계약정보</h4>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
						</div>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="80px">
							<col width="">
							<col width="80px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right">전자계약</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col-auto">
										<button type="button" class="btn btn-primary-gra mr5"  onclick="javascript:sendModusignPanel()" id="_sendModusignPanel"
												<c:if test="${!(empty rent.modusign_id and page.add.MODUSIGN_YN eq 'Y')}">style="display:none;"</c:if>>발송</button>
										<button type="button" class="btn btn-primary-gra"  onclick="javascript:sendContactModusignPanel()" id="_sendContactModusignPanel"
												<c:if test="${!(empty rent.modusign_id and page.add.MODUSIGN_YN eq 'Y')}">style="display:none;"</c:if>>고객앱전송</button>
										<c:if test="${not empty rent.modusign_id and page.add.MODUSIGN_YN eq 'Y' and modusignMap.sign_proc_yn eq 'Y'}">
											<button type="button" class="btn btn-primary-gra"  onclick="javascript:void();" disabled>${modusignMap.modusign_status_label}</button>
											<button type="button" class="btn btn-primary-gra ml5" onclick="javascript:sendModusignCancel()">싸인취소</button>
										</c:if>
										<c:if test="${modusignMap.file_seq ne 0}">
											<a href="javascript:fileDownload('${modusignMap.file_seq}');" style="color: blue; vertical-align: middle;" id="_file_name">${modusignMap.file_name}</a>
											<c:if test="${page.add.MODUSIGN_YN eq 'Y' and modusignMap.modu_modify_yn eq 'N'}">
												<button type="button" class="btn btn-primary-gra ml5" onclick="javascript:fnModusignModify()" id="_fnModusignModify">수정</button>
											</c:if>
										</c:if>
									</div>
									<c:if test="${modusignMap.modu_modify_yn eq 'Y'}">
										<div class="col-auto">(수정중)</div>
									</c:if>
								</div>
<%--								<div class="input-group">--%>
<%--									<c:if test="${empty rent.modusign_id and page.add.MODUSIGN_YN eq 'Y'}">--%>
<%--										<button type="button" class="btn btn-primary-gra mr5"  onclick="javascript:sendModusignPanel()">발송</button>--%>
<%--										<button type="button" class="btn btn-primary-gra"  onclick="javascript:sendContactModusignPanel()">고객앱전송</button>--%>
<%--									</c:if>--%>
<%--									<c:if test="${not empty rent.modusign_id and modusignMap.complete_yn eq 'N'}">--%>
<%--										<button type="button" class="btn btn-primary-gra"  onclick="javascript:void();" disabled>${modusignMap.modusign_status_label}</button>--%>
<%--										<button type="button" class="btn btn-primary-gra ml5" onclick="javascript:sendModusignCancel()">싸인취소</button>--%>
<%--									</c:if>--%>
<%--									<c:if test="${modusignMap.file_seq ne 0}">--%>
<%--										<a href="javascript:fileDownload('${modusignMap.file_seq}');" style="color: blue; vertical-align: middle;">${modusignMap.file_name}</a>--%>
<%--									</c:if>--%>
<%--								</div>--%>
							</td>
							<th class="text-right">종이계약서</th>
							<td class="paper_file_td">
								<div class="paper_file_div">
								</div>
								<button type="button" class="btn btn-primary-gra" id="paperFileBtn" onclick="javascript:fnAddPaperFile()" >파일찾기</button>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /계약정보 -->
					<c:if test="${not empty early}">
						<h4 style="margin-top : 5px;">정산정보<span style="color: red; padding-left : 40px;">※정산금액(음수 : 연체비용정산, 양수 : 조기반납정산)</span></h4>
						<div style="height: 130px; margin-top: 5px">
							<table class="table-border">
								<colgroup>
									<col width="100px">
									<col width="">
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
								<tr>
									<th class="text-right">사용기간</th>
									<td colspan="3">${early.use_st_dt} ~ ${early.use_ed_dt}<span style="display: inline-block;margin-left: 5px">( ${early.use_day_cnt }일 )</span>
										<c:if test="${early.inout_proc_yn ne 'Y'}">
											<span style="margin-left : 3px; color : red">매출처리 필요</span>
										</c:if>
									</td>
									<th class="text-right" >사용금액</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" id="use_amt" name="use_amt" format="decimal" value="${early.use_amt}" readonly="readonly">
											</div>
											<div class="col width16px">원</div>
										</div>
<%--										<input type="text" readonly="readonly" value="${early.use_amt }" id="use_amt" name="use_amt" format="decimal" class="form-control text-right" placeholder="사용금액" style="display: inline-block; width: 100px"><span style="display: inline-block;margin-left: 5px">원</span>--%>
											<%-- <c:if test="${early.inout_proc_yn ne 'Y'}">
                                                <button style="margin-left : 3px;" type="button" class="btn btn-info" onclick="javascript:goSaleForEarlyReturn()">매출처리</button>
                                                <span style="margin-left : 3px; color : red">매출처리 필요</span>
                                            </c:if>
                                            <c:if test="${early.inout_proc_yn eq 'Y'}"><button style="margin-left: 3px;" type="button" onclick="javascript:goSaleInfoForEarly()" class="btn btn-default">매출상세</button></c:if> --%>
									</td>
									<th class="text-right" >휴차료</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col width100px">
												<input type="text" class="form-control text-right" id="mch_nouse_amt" name="mch_nouse_amt" format="minusNum" value="${early.mch_nouse_amt}" readonly="readonly">
											</div>
											<div class="col width16px">원</div>
										</div>
									</td>
								</tr>
								<tr>
									<th class="text-right">정산금액</th>
									<td colspan="3">
										<c:set var="readOnlyAttr" value="${early.inout_proc_yn ne 'Y' ? '' : 'readonly'}"/>
										<input type="text" class="form-control text-right" ${readOnlyAttr} id="return_amt" name="return_amt" value="${early.return_amt }" format="minusNum" placeholder="환불금액" style="display: inline-block; width: 100px">
										<span style="display: inline-block;margin-left: 5px">원</span>
										<c:if test="${early.inout_proc_yn ne 'Y'}">
											<button style="margin-left : 3px;" type="button" class="btn btn-info" onclick="javascript:goSaleForEarlyReturn()">매출처리</button>
										</c:if>
										<c:if test="${early.inout_proc_yn eq 'Y'}">
											<button style="margin-left: 3px;" type="button" onclick="javascript:goSaleInfoForEarly('fnReload')" class="btn btn-default">매출상세</button>
										</c:if>
										<c:if test="${early.vat_return_amt > 0}">
											<button style="margin-left: 3px;" type="button" onclick="javascript:goModifyMessage()" class="btn btn-default">환불반환요청</button>
											<span style="display: inline-block;">VAT포함: <fmt:formatNumber type="number" maxFractionDigits="3" value="${early.vat_return_amt}" />원</span>
										</c:if>
									</td>
									<th class="text-right">정산은행</th>
									<td colspan="3"><input type="text" class="form-control" id="return_bank_name" name="return_bank_name" value="${early.return_bank_name }" placeholder="환불은행" maxlength="10"></td>
								</tr>
								<tr>
									<th class="text-right">정산계좌</th>
									<td colspan="3"><input type="text" class="form-control" id="return_account_no" name="return_account_no" value="${early.return_account_no }" placeholder="환불계좌"></td>
									<th class="text-right">예금주</th>
									<td colspan="3"><input type="text" class="form-control" id="return_deposit_name" name="return_deposit_name" value="${early.return_deposit_name }" placeholder="예금주명"></td>
								</tr>
								<tr>
									<th class="text-right">정산비고</th>
									<td colspan="7" ><textarea class="form-control" style="height: 70px;" id="early_remark" name="early_remark" maxlength="24">${early.remark }</textarea></td>
								</tr>
								</tbody>
							</table>
						</div>
					</c:if>
					<!-- /어태치먼트 -->
				</div>
			</div>
			<div class="row mt10">
				<div class="col-6 out_div">
					<!-- 출고 시 체크 사항 -->
					<div class="title-wrap approval-left">
						<h4>출고 시 체크 사항</h4>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="120px">
							<col width="120px">
							<col width="120px">
							<col width="120px">
							<col width="160px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right rso">출고일자</th>
							<td>
								<div class="input-group width100px">
									<input type="text" class="form-control border-right-0 calDate rbo" id="out_dt" name="out_dt" dateFormat="yyyy-MM-dd" alt="출고일자" value="${rent.out_dt }">
								</div>
							</td>
							<th class="text-right">담당자</th>
							<td>
								<input type="text" class="form-control width100px" readonly value="${rent.out_mem_name}">
								<input type="hidden" id="out_mem_no" name="out_mem_no">
							</td>
							<th class="text-right">출고 시 비고</th>
							<td style="vertical-align: unset;">
								<input type="text" class="form-control width240px" id="out_remark" name="out_remark" maxlength="240" value="${rent.out_remark}"/>
							</td>
						</tr>
						<tr>
							<th class="text-right rso">출고 시 가동시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width60px">
											<input type="text" class="form-control rbo" format="decimal1" id="out_op_hour" name="out_op_hour" alt="출고 시 가동시간" value="${rent.out_op_hour }" min="${rent.op_hour }">
									</div>
									<div class="col width22px">hr</div>
								</div>
							</td>
							<th class="text-right rso">출고시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width60px">
											<input type="text" class="form-control rbo" format="decimal1" id="out_job_hour" name="out_job_hour" alt="출고시간" value="${rent.out_job_hour }" min="${rent.out_job_hour }">
									</div>
									<div class="col width22px">hr</div>
								</div>
							</td>
							<th class="text-right rso">GPS작동상태</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="out_gps_op_yn_check" name="out_gps_op_yn_check" value="Y" <c:if test="${rent.out_gps_op_yn == 'Y'}">checked="checked"</c:if>>
									<label class="form-check-label" for="out_gps_op_yn_check">이상무</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right rso">출고 시 점검사항</th>
							<td colspan="3">
								<c:out value="${rent.o_rental_check_name_str}"></c:out>
<%--								<div name="outfileAllGroup" id="out_file_group" class="table-attfile">--%>
<%--									<c:if test="${empty outFileLeft and empty outFileRight and empty rent.out_dt}">--%>
<%--										<div class="table-attfile" id="out_file_btn_div" style="float:left">--%>
<%--											<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('out')" id="btn_submit_out">파일찾기</button>--%>
<%--										</div>--%>
<%--									</c:if>--%>
<%--									<div name="outfileGroup" id="out_file_left" type_name="차량손상확인-좌측면" class="table-attfile-item">--%>
<%--										<c:if test="${not empty outFileLeft}">--%>
<%--											<a href="javascript:fileDownload(${outFileLeft.file_seq});" style="color: blue; vertical-align: middle;">${outFileLeft.file_name}</a>&nbsp;--%>
<%--											<input type="hidden" name="out_file_left_seq" value="${outFileLeft.file_seq}"/>--%>
<%--											<c:if test="${empty rent.out_dt}">--%>
<%--												<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveGroupFile('out_file_left', 'out')"><i class="material-iconsclose font-18 text-default"></i></button>--%>
<%--											</c:if>--%>
<%--										</c:if>--%>
<%--									</div>--%>
<%--									<div name="outfileGroup" id="out_file_right" type_name="차량손상확인-우측면" class="table-attfile-item">--%>
<%--										<c:if test="${not empty outFileRight}">--%>
<%--											<a href="javascript:fileDownload(${outFileRight.file_seq});" style="color: blue; vertical-align: middle;">${outFileRight.file_name}</a>&nbsp;--%>
<%--											<input type="hidden" name="out_file_right_seq" value="${outFileRight.file_seq}"  />--%>
<%--											<c:if test="${empty rent.out_dt}">--%>
<%--												<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveGroupFile('out_file_right', 'out')"><i class="material-iconsclose font-18 text-default"></i></button>--%>
<%--											</c:if>--%>
<%--										</c:if>--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<th class="text-right rso">출고 시 연료/유입/엔진오일</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width55px">
										<input type="text" class="form-control rbo" format="num" id="out_fuel_qty" name="out_fuel_qty" alt="연료" value="${empty rent.out_dt ? 50 : rent.out_fuel_qty}" min="0" max="100">
									</div>
									<div class="col width25px">%&nbsp;/&nbsp;</div>
									<div class="col width55px">
										<input type="text" class="form-control rbo" format="num" id="out_oil_pressure_qty" name="out_oil_pressure_qty" alt="유입" value="${empty rent.out_dt ? 50 : rent.out_oil_pressure_qty}" min="0" max="100">
									</div>
									<div class="col width25px">%&nbsp;/&nbsp;</div>
									<div class="col width55px">
										<input type="text" class="form-control rbo" format="num" id="out_engine_oil_qty" name="out_engine_oil_qty" alt="엔진오일" value="${empty rent.out_dt ? 50 : rent.out_engine_oil_qty}" min="0" max="100">
									</div>
									<div class="col width20px">%</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right rso">출고 시 사진촬영</th>
							<td colspan="3">
								<div class="table-attfile att_out_file_div" style="width:100%;">
									<div class="table-attfile" style="float:left">
										<c:if test="${empty rent.out_dt}">
											<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:fnAddFile('out');">파일찾기</button>
										</c:if>
									</div>
								</div>
							</td>
							<th class="text-right">점검내역 고객확인여부</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width240px">
										<input type="text" class="form-control rbo" id="cust_check_date" name="cust_check_date" alt="고객확인시간" value="${rent.cust_check_date }" disabled>
									</div>
								</div>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /출고 시 체크 사항 -->
				</div>
				<div class="col-6 return_div">
					<!-- 회수 시 체크 사항 -->
					<div class="title-wrap approval-left">
						<h4>회수 시 체크 사항</h4>
					</div>
					<table class="table-border mt5">
						<colgroup>
							<col width="120px">
							<col width="120px">
							<col width="120px">
							<col width="120px">
							<col width="160px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th class="text-right rsr">회수일자</th>
							<td>
								<div class="input-group width100px">
									<input type="text" class="form-control border-right-0 calDate rbr" id="return_dt" name="return_dt" dateFormat="yyyy-MM-dd" alt="회수일자" value="${rent.return_dt }">
								</div>
							</td>
							<th class="text-right rsr">담당자</th>
							<td>
								<select class="form-control width100px" name="return_mem_no" id="return_mem_no" alt="담당자">
									<option value="">- 선택 -</option>
									<c:forEach var="i" items="${memList}">
										<!-- 퇴직한 직원의 경우도 이미 회수직원이였을 경우에는 나와야하므로 추가 -->
										<c:if test="${i.work_status_cd eq '01' || rent.return_mem_no == i.mem_no}">
											<option value="${i.mem_no}" <c:if test="${rent.return_mem_no == '' ? i.mem_no == SecureUser.mem_no : rent.return_mem_no == i.mem_no}">selected="selected"</c:if>>${i.mem_name}</option>
										</c:if>
									</c:forEach>
								</select>
								<%--									<input type="text" class="form-control width100px" readonly value="${rent.return_mem_name}">--%>
								<%--									<input type="hidden" id="out_mem_no" name="return_mem_no">--%>
							</td>
							<th class="text-right">회수 시 비고</th>
							<td style="vertical-align: unset;">
								<input type="text" class="form-control width240px" id="return_remark" name="return_remark" maxlength="240" value="${rent.return_remark}"/>
							</td>
						</tr>
						<tr>
							<th class="text-right rsr">회수 시 가동시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width60px">
											<input type="text" class="form-control rbr" format="decimal1" id="return_op_hour" name="return_op_hour" alt="회수 시 가동시간" value="${rent.return_op_hour }" min="${rent.out_op_hour}">
									</div>
									<div class="col width22px">hr</div>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
<%--									<c:if test="${page.fnc.F00967_001 ne 'Y'}">--%>
<%--										<button type="button" id="return_op_hour_btn" class="btn btn-primary" onclick="changeReturnOpHour()">수정</button>--%>
<%--									</c:if>--%>
								</div>
							</td>
							<th class="text-right rsr">회수/준비시간</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width60px">
											<input type="text" class="form-control rbr" format="decimal1" id="return_job_hour" name="return_job_hour" alt="회수/준비시간" value="${rent.return_job_hour }" min="${rent.return_job_hour}">
									</div>
									<div class="col width22px">hr</div>
								</div>
							</td>
							<th class="text-right rsr">GPS작동상태</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="return_gps_op_yn_check" name="return_gps_op_yn_check" value="Y" <c:if test="${rent.return_gps_op_yn == 'Y'}">checked="checked"</c:if>>
									<label class="form-check-label" for="return_gps_op_yn_check">이상무</label>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right rsr">회수 시 점검사항</th>
							<td colspan="3">
								<c:out value="${rent.r_rental_check_name_str}"></c:out>
<%--								<div name="returnfileAllGroup" id="return_file_group" class="table-attfile">--%>
<%--									<c:if test="${empty returnFileLeft and empty returnFileRight and empty rent.return_dt and not empty rent.out_dt}">--%>
<%--										<div class="table-attfile" id="return_file_btn_div" style="float:left">--%>
<%--											<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup('return')" id="btn_submit_return">파일찾기</button>--%>
<%--										</div>--%>
<%--									</c:if>--%>
<%--									<div name="returnfileGroup" id="return_file_left" type_name="차량손상확인-좌측면" class="table-attfile-item">--%>
<%--										<c:if test="${not empty returnFileLeft}">--%>
<%--											<a href="javascript:fileDownload(${returnFileLeft.file_seq});" style="color: blue; vertical-align: middle;">${returnFileLeft.file_name}</a>&nbsp;--%>
<%--											<input type="hidden" name="return_file_left_seq" value="${returnFileLeft.file_seq}"/>--%>
<%--											<c:if test="${empty rent.return_dt}">--%>
<%--												<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveGroupFile('return_file_left', 'return')"><i class="material-iconsclose font-18 text-default"></i></button>--%>
<%--											</c:if>--%>
<%--										</c:if>--%>
<%--									</div>--%>
<%--									<div name="returnfileGroup" id="return_file_right" type_name="차량손상확인-우측면" class="table-attfile-item">--%>
<%--										<c:if test="${not empty returnFileRight}">--%>
<%--											<a href="javascript:fileDownload(${returnFileRight.file_seq});" style="color: blue; vertical-align: middle;">${returnFileRight.file_name}</a>&nbsp;--%>
<%--											<input type="hidden" name="return_file_right_seq" value="${returnFileRight.file_seq}"  />--%>
<%--											<c:if test="${empty rent.return_dt}">--%>
<%--												<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveGroupFile('return_file_right', 'return')"><i class="material-iconsclose font-18 text-default"></i></button>--%>
<%--											</c:if>--%>
<%--										</c:if>--%>
<%--									</div>--%>
<%--								</div>--%>
							</td>
							<th class="text-right rsr">회수 시 연료/유입/엔진오일</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col width55px">
										<input type="text" class="form-control rbr" format="num" id="return_fuel_qty" name="return_fuel_qty" alt="연료" value="${empty rent.return_dt ? 50 : rent.return_fuel_qty}" min="0" max="100">
									</div>
									<div class="col width25px">%&nbsp;/&nbsp;</div>
									<div class="col width55px">
										<input type="text" class="form-control rbr" format="num" id="return_oil_pressure_qty" name="return_oil_pressure_qty" alt="유입" value="${empty rent.return_dt ? 50 : rent.return_oil_pressure_qty}" min="0" max="100">
									</div>
									<div class="col width25px">%&nbsp;/&nbsp;</div>
									<div class="col width55px">
										<input type="text" class="form-control rbr" format="num" id="return_engine_oil_qty" name="return_engine_oil_qty" alt="엔진오일" value="${empty rent.return_dt ? 50 : rent.return_engine_oil_qty}" min="0" max="100">
									</div>
									<div class="col width20px">%</div>
								</div>
							</td>
						</tr>
						<tr>
							<th class="text-right rsr">회수 시 사진촬영</th>
							<td colspan="3">
								<div class="table-attfile att_return_file_div" style="width:100%;">
									<div class="table-attfile" style="float:left">
										<c:if test="${not empty rent.out_dt and empty rent.return_dt}">
											<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:fnAddFile('return');">파일찾기</button>
										</c:if>
									</div>
								</div>
							</td>
							<th class="text-right">장비이상여부</th>
							<td>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" onclick="javascript:fnChangeRepair(event)" id="repair_yn" name="repair_yn" value="Y" <c:if test="${rent.repair_yn eq 'Y'}">checked="checked"</c:if>>
									<label class="form-check-label" for="repair_yn">이상발생</label>
								</div>
							</td>
						</tr>
						<tr class="repair-check <c:if test="${rent.repair_yn ne 'Y'}">dpn</c:if>">
							<th class="text-right">장비이상 발생내역</th>
							<td style="vertical-align: unset;" colspan="5">
								<input type="text" class="form-control width520px" id="repair_remark" name="repair_remark" maxlength="240" value="${rent.repair_remark}"/>
							</td>
						</tr>
						</tbody>
					</table>
					<!-- /회수 시 체크 사항 -->
				</div>
			</div>
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
