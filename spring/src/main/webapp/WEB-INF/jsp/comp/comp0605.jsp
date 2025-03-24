<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 부품연관팝업 > 부품연관팝업 > null > 전표바코드조회
-- 작성자 : 성현우
-- 최초 작성일 : 2020-10-06 14:45:05
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<script type="text/javascript">
		$(document).ready(function () {
			$M.getComp("s_doc_barcode_no").focus();
		});

		$(document).scannerDetection({
			timeBeforeScanTest: 200, // wait for the next character for upto 200ms
			startChar: [120], // Prefix character for the cabled scanner (OPL6845R)
			endChar: [13], // be sure the scan is complete if key 13 (enter) is detected
			avgTimeByChar: 40, // it's not a barcode if a character takes longer than 40ms
			minLength: 3,
			onComplete: function (barcode, qty) {
				try {
					if (fnBarcodeRead) {
						fnBarcodeRead(barcode);
					}
					return false;
				} catch (e) {
					console.log(e);
					return false;
				}

			}
		});

		function fnBarcodeRead(barcode) {
		    fnBarcode(barcode);
		}

		function fnBarcode(barcode) {
			if(barcode != "") {
				$M.setValue("s_doc_barcode_no", barcode);
				goBarSearch();
			}
		}

		function goBarSearch() {
			var frm = document.barcode_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_doc_barcode_no"]}) == false) {
				return;
			}

			var param = {
				"s_doc_barcode_no": $M.getValue("s_doc_barcode_no"),
			};

			$M.goNextPageAjax("/part/part0203/barcode", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							fnLayerPopup();
							goPopup(result);
						}
					}
			);
		}

		function goPopup(data) {
			var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
			var params = {
				"doc_barcode_no" : data.bean.doc_barcode_no
			};

			switch (data.bean.doc_barcode_type_cd) {
				case "JOB_REPORT" :
					$M.goNextPage('/part/part0203p02', $M.toGetParam(params), {popupStatus: popupOption});
					break;
				case "PART_TRANS" :
					var loginOrgCode = data.login_org_code;
					if(data.beanPartTrans.from_warehouse_cd == loginOrgCode && data.beanPartTrans.to_warehouse_cd != loginOrgCode) {
						alert("부품출고처리 입니다.");
						$M.goNextPage('/part/part0203p01', $M.toGetParam(params), {popupStatus: popupOption});
					} else if(data.beanPartTrans.from_warehouse_cd != loginOrgCode && data.beanPartTrans.to_warehouse_cd == loginOrgCode) {
						alert("부품입고처리 입니다.");
						$M.goNextPage('/part/part0203p03', $M.toGetParam(params), {popupStatus: popupOption});
					} else {
						alert("처리자 창고가 맞지 않습니다.");
					}
					break;
				case "INOUT_DOC" :
					if(data.beanInoutDoc.part_sale_no == "") {
						$M.goNextPage('/part/part0203p03', $M.toGetParam(params), {popupStatus: popupOption});
					} else {
						$M.goNextPage('/part/part0203p01', $M.toGetParam(params), {popupStatus: popupOption});
					}
					break;
			}
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_doc_barcode_no"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goBarSearch();
				}
			});
		}


		// 레이어 팝업 닫기
		function fnLayerPopup() {
			$.magnificPopup.close();
		}
	</script>
</head>
<body>
<form id="barcode_form" name="barcode_form">
	<div class="popup-wrap width-400" style="margin-top: -100px; margin-left: 150px">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<h2>바코드 스캔</h2>
			<button type="button" class="btn btn-icon" onclick="javascript:fnLayerPopup()"><i class="material-iconsclose"></i></button>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">
			<!-- 폼테이블 -->
			<div>
				<!-- 검색영역 -->
				<div class="search-wrap mt5">
					<table class="table">
						<colgroup>
							<col width="80px">
							<col width="200px">
							<col width="">
						</colgroup>
						<tbody>
						<tr>
							<th>전표 바코드</th>
							<td>
								<input type="text" class="form-control" id="s_doc_barcode_no" name="s_doc_barcode_no" required="required" alt="바코드">
							</td>
							<td class="">
								<button type="button" id="__goBarSearch" class="btn btn-important" style="width: 50px;" onclick="javascript:goBarSearch();">확인</button>
							</td>
						</tr>
						</tbody>
					</table>
				</div>
				<!-- /검색영역 -->

			</div>
			<!-- /폼테이블 -->
		</div>
	</div>
</form>
</body>
</html>