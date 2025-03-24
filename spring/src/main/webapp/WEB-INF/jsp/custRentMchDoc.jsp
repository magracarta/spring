<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 렌탈장비 점검내역(고객용)
-- 작성자 : 이강원
-- 최초 작성일 : 2023-03-28 14:42:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<%--	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>--%>
	<link rel="shortcut icon" type="image/x-icon" href="/static/img/favicon.ico" />
	<title>YK건기 렌탈장비</title>
	<script type="text/javascript" src="/static/js/jquery.min.js?version=1.6"></script>
	<script type='text/javascript' src='/static/js/jquery.mfactory-2.2.js'></script>
	<link rel="stylesheet" type="text/css" href="/static/css/dev.css" />
	<link rel="stylesheet" type="text/css" href="/static/css/yk-tablet.css" />

</head>

<script type="text/javascript">
	$(document).ready(function() {
		if (${inputParam.show_yn eq 'Y'}) {
			document.getElementById("auth-page").style.display = "none";
			$M.setValue("auth_no", "${inputParam.auth_no}");
			goAuthCheck('N');
		} else if(${not empty inputParam.auth_no}) {
			goAuthCheck('Y');
		}
	});

	function goAuthCheck(mobileYn) {
		var param = {
			"auth_no" : $M.getValue("auth_no"),
			"mobile_yn" : mobileYn,
			"show_yn" :"${inputParam.show_yn}"
		}

		$M.goNextPageAjax('/cust/rentalMachineDoc', $M.toGetParam(param), {method:'post'},
				function(result) {
					if(result.success) {
						var rent = result.rent;
						var attachList = result.attachList;
						var outFileList = result.outFileList;
						var returnFileList = result.returnFileList;
						var outFileLeft = result.outFileLeft;
						var outFileRight = result.outFileRight;
						var returnFileLeft = result.returnFileLeft;
						var returnFileRight = result.returnFileRight;
						var mode = result.mode;
						var confirmYn = result.confirm_yn;

						if(confirmYn == "Y" || ${inputParam.show_yn eq 'Y'}) {
							document.getElementById("return-btn").style.display = "none";
							document.getElementById("return-check").style.display = "none";
						}

						document.getElementById("rental_doc_no").value = result.rental_doc_no;
						document.getElementById("mch_doc_seq_no").value = result.mch_doc_seq_no;
						document.getElementById("mode").value = result.mode;


						document.getElementById("out_fuel_qty").value = rent.out_fuel_qty;
						document.getElementById("out_oil_pressure_qty").value = rent.out_oil_pressure_qty;
						document.getElementById("out_engine_oil_qty").value = rent.out_engine_oil_qty;
						document.getElementById("return_fuel_qty").value = rent.return_fuel_qty;
						document.getElementById("return_oil_pressure_qty").value = rent.return_oil_pressure_qty;
						document.getElementById("return_engine_oil_qty").value = rent.return_engine_oil_qty;

						document.getElementById("out_fuel_qty").style.backgroundSize = (document.getElementById("out_fuel_qty").value - 0) * 100 / (100 - 0) + '% 100%'
						document.getElementById("out_oil_pressure_qty").style.backgroundSize = (document.getElementById("out_oil_pressure_qty").value - 0) * 100 / (100 - 0) + '% 100%'
						document.getElementById("out_engine_oil_qty").style.backgroundSize = (document.getElementById("out_engine_oil_qty").value - 0) * 100 / (100 - 0) + '% 100%'
						document.getElementById("return_fuel_qty").style.backgroundSize = (document.getElementById("return_fuel_qty").value - 0) * 100 / (100 - 0) + '% 100%'
						document.getElementById("return_oil_pressure_qty").style.backgroundSize = (document.getElementById("return_oil_pressure_qty").value - 0) * 100 / (100 - 0) + '% 100%'
						document.getElementById("return_engine_oil_qty").style.backgroundSize = (document.getElementById("return_engine_oil_qty").value - 0) * 100 / (100 - 0) + '% 100%'

						$(".title").html("렌탈장비 " + (mode == "O" ? "출고" : "회수") + "점검내역");
						if(mode == "O") {
							document.getElementById("info-return").style.display = "none";
							document.getElementById("return-check").style.display = "none";
						} else {
							document.getElementById("info-out").style.display = "none";
						}

						var keys = Object.keys(rent);
						for(var key in keys) {
							$("#"+keys[key]).html(rent[keys[key]]);
						}


						for(var i in attachList) {
							var htmlStr = "";
							htmlStr += '<tr>';
							htmlStr += '	<td>' + attachList[i].real_attach_name + '</td>';
							htmlStr += '	<td>' + attachList[i].part_no + '</td>';
							htmlStr += '	<td class="text-center">' + attachList[i].qty + '</td>';
							htmlStr += '	<td>' + attachList[i].rental_attach_no + '</td>';
							htmlStr += '	<td class="text-end">' + attachList[i].amt + '</td>';
							htmlStr += '</tr>';

							$("#attachList").append(htmlStr);
						}

						// 출고 시 사진촬영 setting
						// 출고 시 사진촬영이 없다면 출고 점검사항도 없음
						if(outFileList == null) {
							document.getElementById("outFileList").style.display = "none";
							document.getElementById("outFile").style.display = "none";
						}
						for(var i in outFileList) {
							var htmlStr = "";
							htmlStr += '<div class="col-auto">';
							htmlStr += '	<div class="thumb-list-item doc">';
							htmlStr += '		<div class="thumb">';
							htmlStr += '			<img src="/file/svc/' + outFileList[i].file_seq + '" onclick="javascript:modalDisplay(\'block\',\'' + outFileList[i].file_seq + '\')" class="ori-img" alt="">';
							htmlStr += '		</div>';
							htmlStr += '		<div class="file-name-1line">' + outFileList[i].file_name + '</div>';
							htmlStr += '	</div>';
							htmlStr += '</div>';

							$("#outFileListItems").append(htmlStr);
						}

						// 회수 시 사진촬영 setting
						// 회수 시 사진촬영이 없다면 회수 점검사항도 없음
						if(returnFileList == null) {
							document.getElementById("returnFileList").style.display = "none";
							document.getElementById("returnFile").style.display = "none";
						}
						for(var i in returnFileList) {
							var htmlStr = "";
							htmlStr += '<div class="col-auto">';
							htmlStr += '	<div class="thumb-list-item doc">';
							htmlStr += '		<div class="thumb">';
							htmlStr += '			<img src="/file/svc/' + returnFileList[i].file_seq + '" onclick="javascript:modalDisplay(\'block\',\'' + returnFileList[i].file_seq + '\')" class="ori-img" alt="">';
							htmlStr += '		</div>';
							htmlStr += '		<div class="file-name-1line">' + returnFileList[i].file_name + '</div>';
							htmlStr += '	</div>';
							htmlStr += '</div>';

							$("#returnFileListItems").append(htmlStr);
						}

						// 차량손상확인-좌측이 없으면 우측도 없으므로 손상확인 숨김처리
						document.getElementById("outFileCheck").style.display = "none";
						document.getElementById("returnFileCheck").style.display = "none";
						// if(outFileLeft == null || outFileLeft.file_seq == "") {
						// 	document.getElementById("outFileCheck").style.display = "none";
						// } else {
						// 	$("#outFileLeft").append('<a href="javascript:modalDisplay(\'block\',\'' + outFileLeft.file_seq + '\')" class="body text-center mt-16 d-block">'
						// 			+ '<img src="/file/svc/' + outFileLeft.file_seq + '" class="ori-img" style="width:100%;" alt="차량손상확인 [좌측면]">'
						// 			+ '</a>');
						// 	$("#outFileRight").append('<a href="javascript:modalDisplay(\'block\',\'' + outFileRight.file_seq + '\')" class="body text-center mt-16 d-block">'
						// 			+ '<img src="/file/svc/' + outFileRight.file_seq + '" class="ori-img" style="width:100%;" alt="차량손상확인 [우측면]">'
						// 			+ '</a>');
						// }
						// if(returnFileLeft == null || returnFileLeft.file_seq == "") {
						// 	document.getElementById("returnFileCheck").style.display = "none";
						// } else {
						// 	$("#returnFileLeft").append('<a href="javascript:modalDisplay(\'block\',\'' + returnFileLeft.file_seq + '\');" class="body text-center mt-16 d-block">'
						// 			+ '<img src="/file/svc/' + returnFileLeft.file_seq + '" class="ori-img" style="width:100%;" alt="차량손상확인 [좌측면]">'
						// 			+ '</a>');
						// 	$("#returnFileRight").append('<a href="javascript:modalDisplay(\'block\',\'' + returnFileRight.file_seq + '\');" class="body text-center mt-16 d-block">'
						// 			+ '<img src="/file/svc/' + returnFileRight.file_seq + '" class="ori-img" style="width:100%;" alt="차량손상확인 [우측면]">'
						// 			+ '</a>');
						// }

						document.getElementById("auth-page").style.display = "none";
						document.getElementById("web-doc-page").style.display = "block";

						// 출고/회수시 점검사항 세팅
						if (rent.o_no_check_yn == "Y") {
							$("#o_no_check_yn").prop("checked", true);
						}
						var innerHtml = '';
						for (var i=0; i<result.up_rental_check_list.length; i++) {
							var upCheckObj = result.up_rental_check_list[i];
							innerHtml += '<div class="font-size-base mb-6 mt-12">- '+ upCheckObj.code_name +'</div>';
							innerHtml += '	<div class="row g-6 align-items-start">';

							for (var j=0; j<result.o_rental_check_list.length; j++) {
								var checkObj = result.o_rental_check_list[j];
								if (upCheckObj.code_value.substring(0, 2) === checkObj.code_value.substring(0, 2)) {
									innerHtml += '		<div class="col-6">';
									innerHtml += '			<div class="check-list-item">';
									innerHtml += '				<input type="checkbox" id='+ checkObj.code_value +' class="check-list-input" disabled '+ (checkObj.checked_yn=="Y"? 'checked':'') +'>';
									innerHtml += '				<label for='+ checkObj.code_value +'>'+ checkObj.code_name +'</label>';
									innerHtml += '			</div>';
									innerHtml += '		</div>';
								}
							}

							innerHtml += '	</div>';
							innerHtml += '</div>';
						}
						document.getElementById("o_check_list").innerHTML = innerHtml;

						if (rent.r_no_check_yn == "Y") {
							$("#r_no_check_yn").prop("checked", true);
						}
						innerHtml = '';
						for (var i=0; i<result.up_rental_check_list.length; i++) {
							var upCheckObj = result.up_rental_check_list[i];
							innerHtml += '<div class="font-size-base mb-6 mt-12">- '+ upCheckObj.code_name +'</div>';
							innerHtml += '	<div class="row g-6 align-items-start">';

							for (var j=0; j<result.r_rental_check_list.length; j++) {
								var checkObj = result.r_rental_check_list[j];
								if (upCheckObj.code_value.substring(0, 2) === checkObj.code_value.substring(0, 2)) {
									innerHtml += '		<div class="col-6">';
									innerHtml += '			<div class="check-list-item">';
									innerHtml += '				<input type="checkbox" id='+ checkObj.code_value +' class="check-list-input" disabled '+ (checkObj.checked_yn=="Y"? 'checked':'') +'>';
									innerHtml += '				<label for='+ checkObj.code_value +'>'+ checkObj.code_name +'</label>';
									innerHtml += '			</div>';
									innerHtml += '		</div>';
								}
							}

							innerHtml += '	</div>';
							innerHtml += '</div>';
						}
						document.getElementById("r_check_list").innerHTML = innerHtml;
					}
				}
		);
	}

	function enter(fieldObj) {
		var field = ["auth_no"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goAuthCheck('N');
			}
		});
	}

	function modalDisplay(text, fileSeq){
		document.getElementById("modal").style.display = text;
		document.getElementById("modal_img").src = '/file/svc/'+fileSeq;
	}

	function goCheck() {
		if(document.getElementById("mode").value == "O") {
			fnClose();
		} else {
			if(!document.getElementById("chk01").checked) {
				alert("체크항목을 확인 해주시기 바랍니다.");
				$("#chk01").focus();
				return;
			}

			var param = {
				"rental_doc_no" : document.getElementById("rental_doc_no").value,
				"seq_no" : document.getElementById("mch_doc_seq_no").value,
			}

			$M.goNextPageAjax('/cust/rentalMachineDoc/check', $M.toGetParam(param), {method:'post'},
				function(result) {
					if (result.success) {
						alert("회수점검내역 확인이 완료되었습니다.");
						fnClose();
					}
			});
		}
	}

	function fnClose() {
		window.close();
	}
</script>
<style>
	.modal_image_large {
		display: none; /* 모달창 숨겨 놓기 */
		position: fixed;
		z-index: 1; /* 모달창을 제일 앞에 두기 */
		padding-top: 50px;
		left: 0; top: 0;
		width: 100%; height: 100%;
		overflow: auto; /* 스크롤 허용 auto */
		cursor: pointer; /* 마우스 손가락모양 */
		background-color: rgba(0, 0, 0, 0.8);
	}
	/* 모달창 이미지 */
	.modal_image_large_cotent {
		margin: auto;
		display: block;
		width: 50%; height: auto;
		max-width: 1000px;
		border-radius: 10px;
		animation-name: zoomzoom;
		animation-duration: 0.8s;
	}
	/* 모달창 애니메이션 추가 */
	@keyframes zoomzoom {
		from {transform: scale(0)}
		to {transform: scale(1)}
	}

	.check-list-input ~ label {
		width: 100%;
		padding: 0.5rem 0.35rem;
		border-radius: 0.25rem;
		border: 1px solid var(--border-color);
	}
	.check-list-input:checked ~ label:before {
		background-image: url(/static/img/cust/icon-check-item-checked.svg);
	}

	.check-list-input ~ label:before {
		content: "";
		display: inline-block;
		vertical-align: middle;
		width: 1.25rem;
		height: 1.25rem;
		margin-right: 0.25rem;
		background-image: url(/static/img/cust/icon-check-item-unchecked.svg);
	}

	.icon-close-black-lg {
		width: 3rem;
		height: 3rem;
		background-image: url(/static/img/cust/icon-close-black-lg.svg);
	}

	.icon-close-white-lg {
		width: 3rem;
		height: 3rem;
		background-image: url(/static/img/cust/icon-close-white-lg.svg);
	}

	.web-doc-page .bottom-btn-group {
		bottom: 0 !important;
		background-color: var(--light);
		border-top: 1px solid var(--border-color);
	}

	.btn-grid {
		display: flex;
		gap: 0.375rem;
	}

	.web-doc-page {
		padding-bottom: 6rem;
	}

	.bottom-btn-group {
		width : 100%;
		max-width: 1280px;
		margin : auto;
		border: 1px solid var(--border-color);
	}
</style>

<body>
<input type="hidden" id="mch_doc_seq_no" name="mch_doc_seq_no" value="">
<input type="hidden" id="rental_doc_no" name="rental_doc_no" value="">
<input type="hidden" id="mode" name="mode" value="">
<div class="auth-page" id="auth-page">
	<div class="popup-wrap" style="width: 400px; border: 1.5px solid #ddd; border-radius: 1.1rem;"> <!-- full클래스 추가해주면 전체페이지 팝업 -->
		<!-- 상단 타이틀 영역 -->
		<div class="popup-top">
			<div class="header">
				<span class="title">본인확인</span>
<%--				<div>--%>
<%--					<button class="icon-close-white-lg" onclick="javascript:fnClose();">--%>
<%--						<span class="visually-hidden">이전페이지로 이동</span>--%>
<%--					</button>--%>
<%--				</div>--%>
			</div>
		</div>
		<!-- /상단 타이틀 영역 -->

		<div class="popup-content">
			<table class="table">
				<colgroup>
					<col style="width: 100px;">
					<col>
				</colgroup>
				<tbody>
				<tr>
					<th class="text-end">인증번호</th>
					<td>
						<div class="row gx-6">
							<div class="col">
								<input type="password" id="auth_no" name="auth_no" class="form-control" placeholder="숫자 6자리" maxlength="6">
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<div class="row gx-6">
							<div class="col" style="background-color : #ddd; border: 1.5px solid #ddd; border-radius: 0.375rem; padding: 0.375rem 2.5rem 0.375rem 0.75rem;">
								① 고객님 문자로 수신된 인증번호를 입력해주세요(숫자 6자리)<br>
								② &lt;인증&gt;버튼을 클릭해주세요.
							</div>
						</div>
					</td>
				</tr>
				</tbody>
			</table>

			<div class="popup-bottom-btn-group text-center">
				<button class="btn btn-primary" onclick="javascript:goAuthCheck('N');">인증</button>
			</div>
		</div>
	</div>
<%--	<div class="popup-wrap width-400" style="margin-top: -250px; ">--%>
<%--		<!-- 타이틀영역 -->--%>
<%--		<div class="main-title">--%>
<%--			<h2>본인확인</h2>--%>
<%--		</div>--%>
<%--		<!-- /타이틀영역 -->--%>
<%--		<div class="content-wrap">--%>
<%--			<div class="item-group">--%>
<%--				<div class="form-group">--%>
<%--					<div class="form-row inline-pd">--%>
<%--						<label class="col-3 text-right col-form-label">인증번호</label>--%>
<%--						<div class="col-7" >--%>
<%--							<input type="password" id="auth_no" name="auth_no" class="form-control" placeholder="숫자 6자리">--%>
<%--						</div>--%>
<%--						<div class="col-2">--%>
<%--							<button type="button" class="auth-btn btn-info" onclick="javascript:goAuthCheck();" style="width: 100%;">인증</button>--%>
<%--						</div>--%>
<%--					</div>--%>
<%--				</div>--%>
<%--			</div>--%>

<%--			<div class="alert alert-secondary mt10">--%>
<%--				<div class="title">--%>
<%--					<i class="material-iconserror font-16"></i>--%>
<%--					<span>인증절차</span>--%>
<%--				</div>--%>
<%--				<ol>--%>
<%--					<li>① 고객님 문자로 수신된 인증번호를 입력해주세요(숫자 6자리)</li>--%>
<%--					<li>② &lt;인증&gt;버튼 클릭해주세요.</li>--%>
<%--				</ol>--%>
<%--			</div>--%>

<%--		</div>--%>
<%--	</div>--%>
</div>
<div class="web-doc-page" id="web-doc-page" style="display : none;">

	<div class="web-doc-title">
		<div class="title-wrap">
        <span class="ver-line">
          <img src="/static/img/top-logo-color.svg" alt="" class="yk-logo">
        </span>
			<span class="title"></span>
		</div>
<%--		<c:if test="${not empty inputParam.auth_no}">--%>
<%--		<div style="float : right;">--%>
<%--			<button class="icon-close-black-lg" onclick="javascript:fnClose();">--%>
<%--				<span class="visually-hidden">이전페이지로 이동</span>--%>
<%--			</button>--%>
<%--		</div>--%>
<%--		</c:if>--%>
	</div>

	<!-- 장비정보 -->
	<div class="p-16">
		<div class="sub-title-wrap">
			<div class="left">장비정보</div>
		</div>
		<div class="mt-16">
			<div class="pt-12 border-top">
				<table class="table">
					<colgroup>
						<col style="width: 15%">
						<col style="width: 18%">
						<col style="width: 15%">
						<col style="width: 18%">
						<col style="width: 15%">
						<col>
					</colgroup>
					<tbody>
					<tr>
						<th class="text-end">메이커</th>
						<td id="maker_name"></td>
						<th class="text-end">모델</th>
						<td id="machine_name"></td>
						<th class="text-end">연식</th>
						<td id="made_dt"></td>
					</tr>
					<tr>
						<th class="text-end">차대번호</th>
						<td id="body_no"></td>
						<th class="text-end">번호판번호</th>
						<td id="mreg_no"></td>
						<th class="text-end">GPS</th>
						<td><span id="gps_no"></span>&nbsp;<span id="gps_type_name"></span></td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- /장비정보 -->

	<!-- 고객정보 -->
	<div class="p-16">
		<div class="sub-title-wrap">
			<div class="left">고객정보</div>
		</div>
		<div class="mt-16">
			<div class="pt-12 border-top">
				<table class="table">
					<colgroup>
						<col style="width: 15%">
						<col style="width: 18%">
						<col style="width: 15%">
						<col style="width: 18%">
						<col style="width: 15%">
						<col>
					</colgroup>
					<tbody>
					<tr>
						<th class="text-end">고객명</th>
						<td id="cust_name"></td>
						<th class="text-end">회사명</th>
						<td id="breg_name"></td>
						<th class="text-end">핸드폰</th>
						<td id="hp_no"></td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- /고객정보 -->

	<!-- 렌탈정보 -->
	<div class="p-16">
		<div class="sub-title-wrap">
			<div class="left">렌탈정보</div>
		</div>
		<div class="mt-16">
			<div class="pt-12 border-top">
				<table class="table">
					<colgroup>
						<col style="width: 22%">
						<col>
						<col style="width: 15%">
						<col>
					</colgroup>
					<tbody>
					<tr>
						<th class="text-end">렌탈기간</th>
						<td><span id="rental_st_dt"></span>&nbsp; ~ &nbsp;<span id="rental_ed_dt"></span>&nbsp; (<span id="day_cnt"></span>)</td>
						<th class="text-end">인도방법</th>
						<td id="rental_delivery_name"></td>
					</tr>
					<tr>
						<th class="text-end">최종렌탈료</th>
						<td colspan="3">
							<span class="ver-line" id="rental_amt"></span>
							<span class="text-primary" id="vat_rental_amt"></span>
						</td>
					</tr>
					<tr>
						<th class="text-end">배송지</th>
						<td colspan="3" id="delivery_addr"></td>
					</tr>
					<tr>
						<th class="text-end">계약 시 특이사항</th>
						<td colspan="3" id="remark"></td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- /렌탈정보 -->

	<!-- 어태치먼트 -->
	<div class="p-16">
		<div class="sub-title-wrap">
			<div class="left">어태치먼트</div>
		</div>
		<div class="mt-16">
			<div class="pt-12 border-top">
				<table class="table">
					<colgroup>
						<col>
						<col>
						<col>
						<col>
						<col>
					</colgroup>
					<thead>
					<tr>
						<th class="text-center">어태치먼트명</th>
						<th class="text-center">부품번호</th>
						<th class="text-center">수량</th>
						<th class="text-center">관리번호</th>
						<th class="text-center">렌탈금액</th>
					</tr>
					</thead>
					<tbody id="attachList">
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- /어태치먼트 -->

	<!-- 출고 시 체크사항 -->
	<div class="p-16" id="info-out">
		<div class="sub-title-wrap">
			<div class="left">출고 시 체크사항</div>
		</div>
		<div class="mt-16">
			<div class="pt-12 border-top">
				<table class="table">
					<colgroup>
						<col style="width: 22%">
						<col>
						<col style="width: 15%">
						<col>
					</colgroup>
					<tbody>
					<tr>
						<th class="text-end">출고일자</th>
						<td id="out_dt"></td>
						<th class="text-end">담당자</th>
						<td id="out_mem_name"></td>
					</tr>
					<tr>
						<th class="text-end">출고 시 가동시간</th>
						<td id="out_op_hour"></td>
				<th class="text-end">출고시간</th>
				<td id="out_job_hour"></td>
				</tr>
					<%-- TODO : GPS작동유무 구현 후 추가필요 --%>
<%--				<tr>--%>
<%--					<th class="text-end">GPS작동유무</th>--%>
<%--					<td colspan="3">수신기 ON</td>--%>
<%--				</tr>--%>
				</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- /출고 시 체크사항 -->

	<!-- 회수 시 체크사항 -->
	<div class="p-16" id="info-return">
		<div class="sub-title-wrap">
			<div class="left">회수 시 체크사항</div>
		</div>
		<div class="mt-16">
			<div class="pt-12 border-top">
				<table class="table">
					<colgroup>
						<col style="width: 22%">
						<col>
						<col style="width: 15%">
						<col>
					</colgroup>
					<tbody>
					<tr>
						<th class="text-end">회수일자</th>
						<td id="return_dt"></td>
						<th class="text-end">담당자</th>
						<td id="return_mem_name"></td>
					</tr>
					<tr>
						<th class="text-end">회수 시 가동시간</th>
						<td id="return_op_hour"></td>
						<th class="text-end">회수/준비시간</th>
						<td id="return_job_hour"></td>
					</tr>
					<%-- TODO : GPS작동유무 구현 후 추가필요 --%>
<%--					<tr>--%>
<%--						<th class="text-end">GPS작동유무</th>--%>
<%--						<td colspan="3">수신기 ON</td>--%>
<%--					</tr>--%>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<!-- /회수 시 체크사항 -->

	<!-- 출고 시 사진촬영 -->
	<div class="p-16" id="outFileList">
		<div class="sub-title-wrap">
			<div class="left">출고 시 사진촬영</div>
		</div>
		<div class="mt-12">
			<div class="pt-12 border-top">

				<div class="boxing">
					<div class="row g-16 align-items-start thumb-list-group" id="outFileListItems">
					</div>

				</div>

			</div>
		</div>
	</div>
	<!-- /출고 시 사진촬영 -->

	<!-- 출고 시 점검사항 -->
	<div class="p-16" id="outFile">
		<div class="sub-title-wrap">
			<div class="left">출고 시 점검사항</div>
		</div>
		<div class="mt-12 pt-12 border-top">
			<div class="row g-6">
				<div class="col-6">
					<div class="check-list-item">
						<input type="checkbox" id="o_no_check_yn" class="check-list-input" disabled>
						<label for="o_no_check_yn">이상없음</label>
					</div>
				</div>
			</div>
		</div>
		<div id="o_check_list"></div>
		<div class="mt-12">
			<div class="pt-12 border-top">
				<div class="row gx-16 align-items-start" id="outFileCheck">
					<div class="col-6">
						<div class="boxing bg-white">
							<div class="header border-bottom pb-12">
								<div class="d-flex justify-content-between align-items-center">
									<div class="left">
										차량손상확인-좌측면
									</div>
									<div class="right">
										<div class="right text-primary">[점검완료]</div>
									</div>
								</div>
							</div>
							<div id="outFileLeft">
							</div>
						</div>
					</div>
					<div class="col-6">
						<div class="boxing bg-white">
							<div class="header border-bottom pb-12">
								<div class="d-flex justify-content-between align-items-center">
									<div class="left">
										차량손상확인-우측면
									</div>
									<div class="right">
										<div class="right text-primary">[점검완료]</div>
									</div>
								</div>
							</div>
							<div id="outFileRight">
							</div>
						</div>
					</div>
				</div>
			</div>

			<div>
				<div class="boxing mt-12">
					<div class="font-title-4">출고 시 연료량</div>
					<div class="d-flex justify-content-between align-items-center mt-6">
						<strong class="d-flex" style="flex-basis: 40px;">E</strong>
						<input type="range" value="0" min="0" max="100" id="out_fuel_qty" class="green" disabled>
						<strong class="d-flex justify-content-end" style="flex-basis: 40px;">F</strong>
					</div>
				</div>

				<div class="boxing mt-12">
					<div class="font-title-4">출고 시 유압량</div>
					<div class="d-flex justify-content-between align-items-center mt-6">
						<strong class="d-flex" style="flex-basis: 40px;">E</strong>
						<input type="range" value="50" min="0" max="100" id="out_oil_pressure_qty" class="blue" disabled>
						<strong class="d-flex justify-content-end" style="flex-basis: 40px;">F</strong>
					</div>
				</div>

				<div class="boxing mt-12">
					<div class="font-title-4">출고 시 엔진오일</div>
					<div class="d-flex justify-content-between align-items-center mt-6">
						<strong class="d-flex" style="flex-basis: 40px;">E</strong>
						<input type="range" value="50" min="0" max="100" id="out_engine_oil_qty" class="red" disabled>
						<strong class="d-flex justify-content-end" style="flex-basis: 40px;">F</strong>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- /출고 시 점검사항 -->

	<!-- 회수 시 사진촬영 -->
	<div class="p-16" id="returnFileList">
		<div class="sub-title-wrap">
			<div class="left">회수 시 사진촬영</div>
		</div>
		<div class="mt-12">
			<div class="pt-12 border-top">

				<div class="boxing">
					<div class="row g-16 align-items-start thumb-list-group" id="returnFileListItems">
					</div>

				</div>

			</div>
		</div>
	</div>
	<!-- /회수 시 사진촬영 -->

	<!-- 회수 시 점검사항 -->
	<div class="p-16" id="returnFile">
		<div class="sub-title-wrap">
			<div class="left">회수 시 점검사항</div>
		</div>
		<div class="mt-12 pt-12 border-top">
			<div class="row g-6">
				<div class="col-6">
					<div class="check-list-item">
						<input type="checkbox" id="r_no_check_yn" class="check-list-input" disabled>
						<label for="r_no_check_yn">이상없음</label>
					</div>
				</div>
			</div>
		</div>
		<div id="r_check_list"></div>
		<div class="mt-12">
			<div class="pt-12 border-top">
				<div class="row gx-16 align-items-start" id="returnFileCheck">
					<div class="col-6">
						<div class="boxing bg-white">
							<div class="header border-bottom pb-12">
								<div class="d-flex justify-content-between align-items-center">
									<div class="left">
										차량손상확인-좌측면
									</div>
									<div class="right">
										<div class="right text-primary">[점검완료]</div>
									</div>
								</div>
							</div>
							<div id="returnFileLeft">
							</div>
						</div>
					</div>
					<div class="col-6">
						<div class="boxing bg-white">
							<div class="header border-bottom pb-12">
								<div class="d-flex justify-content-between align-items-center">
									<div class="left">
										차량손상확인-우측면
									</div>
									<div class="right">
										<div class="right text-primary">[점검완료]</div>
									</div>
								</div>
							</div>
							<div id="returnFileRight">
							</div>
						</div>
					</div>
				</div>
			</div>

			<div>
				<div class="boxing mt-12">
					<div class="font-title-4">회수 시 연료량</div>
					<div class="d-flex justify-content-between align-items-center mt-6">
						<strong class="d-flex" style="flex-basis: 40px;">E</strong>
						<input type="range" value="50" min="0" max="100" id="return_fuel_qty" class="green" disabled>
						<strong class="d-flex justify-content-end" style="flex-basis: 40px;">F</strong>
					</div>
				</div>

				<div class="boxing mt-12">
					<div class="font-title-4">회수 시 유압량</div>
					<div class="d-flex justify-content-between align-items-center mt-6">
						<strong class="d-flex" style="flex-basis: 40px;">E</strong>
						<input type="range" value="50" min="0" max="100" id="return_oil_pressure_qty" class="blue" disabled>
						<strong class="d-flex justify-content-end" style="flex-basis: 40px;">F</strong>
					</div>
				</div>

				<div class="boxing mt-12">
					<div class="font-title-4">회수 시 엔진오일</div>
					<div class="d-flex justify-content-between align-items-center mt-6">
						<strong class="d-flex" style="flex-basis: 40px;">E</strong>
						<input type="range" value="50" min="0" max="100" id="return_engine_oil_qty" class="red" disabled>
						<strong class="d-flex justify-content-end" style="flex-basis: 40px;">F</strong>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="p-16" id="return-check">
		<div class="check-list-item">
			<input type="checkbox" id="chk01" class="check-list-input">
			<label for="chk01">렌탈장비를 이상 없이 반납했습니다.</label>
		</div>
	</div>
	<div class="bottom-btn-group" id="return-btn">
		<div class="btn-grid">
			<button class="btn btn-primary" onclick="javascript:goCheck();">확인</button>
		</div>
	</div>
	<!-- /회수 시 점검사항 -->
	<div class="modal_image_large" id="modal" onclick="javascript:modalDisplay('none', 0)">
		<img class="modal_image_large_cotent" id="modal_img" onclick="javascript:modalDisplay('none', 0)">
	</div>

</div>
<%--<script src="/static/js/range.js"></script> <!-- 게이지바 스크립트 -->--%>
</body>

</html>