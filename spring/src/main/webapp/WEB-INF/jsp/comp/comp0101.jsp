<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 즐겨찾기 > null > 즐겨찾기설정
-- 작성자 : 손광진
-- 최초 작성일 : 2019-12-19 14:23:37
------------------------------------------------------------------------------------------------------------------%>

	<script type="text/javascript">
		$(document).ready(function() {
			initFavoriteAllList();
		});
		
		// 회원이 즐겨찾기 한 메뉴 표시
		function initFavoriteAllList() {
			$M.goNextPageAjax("/comp/comp0101/bookmark", "", {method : 'get'},
				function(result) {
					if(result.success) {
						for(var i=0; i < result.list.length; i++) {
							var menuSeq = result.list[i].menu_seq;
							console.log(menuSeq);
							$("#" + menuSeq).children("i").attr("class", "icon-btn-favorite");
						};
					};
				}
			);	 
		}

		// 즐겨찾기 클릭 별표시
		$(".alert-three").css("cursor", "pointer").click(function() {
			if($(this).children("i").hasClass("icon-btn-favorite")) {
				$(this).children("i").attr("class", "icon-btn-favorite-no");
			} else {
				$(this).children("i").attr("class", "icon-btn-favorite");
			};
		});
		
		// 즐겨찾기 체크 초기화
		function fnRestCheckBookMark() {
			$(".alert-three").children(".icon-btn-favorite").attr("class","icon-btn-favorite-no");
		}

		// 즐겨찾기 저장
		function goSave() {
			var removeFlag 		 = "N"; 	// remove_all_yn = N 초기값
			var bookmarkSave	 = [];		// 저장할 즐겨찾기 메뉴 seq값
			var bookmarkAdd	  	 = "";		// 새로 저장할 메뉴 seq값들
			var bookmarkCnt 	 = 0;		// 북마크 개수
			$(".alert-three").children(".icon-btn-favorite").each(function(i) {
				bookmarkAdd	= $(this).closest("li").attr("id");
				console.log(bookmarkAdd);
				bookmarkCnt = i+1;
			  	bookmarkSave.push(bookmarkAdd);
			});
		  	console.log(bookmarkCnt);
			// 저장할 즐겨찾기메뉴가 없으면 remove_all_yn = Y
			if(bookmarkCnt == 0) {
				removeFlag = "Y";
			} else if(bookmarkCnt > 20) {
				alert("즐겨찾기 메뉴 추가는 최대 20개로 제한합니다.");
				return false;
			};
			var param = {
					menu_seq_str : $M.getArrStr(bookmarkSave),
					remove_all_yn : removeFlag
			};
			console.log(param);
			$M.goNextPageAjaxSave("/comp/comp0101", $M.toGetParam(param), { method : 'POST'},
				function(result) {
					if(result.success) {
						// 저장 후 즐겨찾기 목록 재실행
						// goBookmarkMenu(); -> 즐겨찾기가 업무메뉴로 이동해서 다시 조회안함 (다시누르면 어차피 다시조회하므로 이슈제기하기 전까지 막음)
						fnRefreshLeftFavorit();
						$.magnificPopup.close();
					};
				}
			);
		}
		
		// 레이어 팝업닫기
		function fnClose() {
			$.magnificPopup.close();
		}
		
	</script>

<!-- 팝업 -->
    <div class="popup-wrap width-100per bookmarkWarp">
<!-- 타이틀영역 -->
        <div class="main-title">
            <h2>즐겨찾기 설정</h2>
            <button type="button" class="btn btn-icon" onclick="fnClose()"><i class="material-iconsclose"></i></button>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap" id="menuList">
			<div class="row mt-9">
				<div class="item-group col-3 favorite-select">
					<h5>My</h5>
					<ul>
						<c:forEach var="item" items="${map.my}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
				<div class="item-group col-3 favorite-select">
					<h5>고객</h5>
					<ul>
						<c:forEach var="item" items="${map.cust}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
				<div class="item-group col-3 favorite-select">
					<h5>마케팅</h5>
					<ul>
						<c:forEach var="item" items="${map.sale}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
				<div class="item-group col-3 favorite-select">
					<h5>부품</h5>
					<ul>
						<c:forEach var="item" items="${map.part}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
			</div>

			<div class="row">
				<div class="item-group col-3 favorite-select">
					<h5>서비스</h5>
					<ul>
						<c:forEach var="item" items="${map.service}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
				<div class="item-group col-3 favorite-select">
					<h5>렌탈</h5>
					<ul>
						<c:forEach var="item" items="${map.rental}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
				<div class="item-group col-3 favorite-select">
					<h5>회계</h5>
					<ul>
						<c:forEach var="item" items="${map.account}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
				<div class="item-group col-3 favorite-select">
					<h5>공통</h5>
					<ul>
						<c:forEach var="item" items="${map.comm}"> 
							<c:if test="${item.menu_depth == 2}"><li class="alert-secondary">${item.menu_name}</li></c:if>
							<c:if test="${item.menu_depth == 3}"><li class="alert-three" id="${item.menu_seq}">${item.menu_name}<i class="icon-btn-favorite-no"></i></li></c:if>
						</c:forEach>
					</ul>
				</div>
			</div>

            <div class="alert alert-secondary mt10">
                <div class="title">
                    <i class="material-iconserror font-16"></i>
                    메뉴 추가 안내사항
                </div>
                <ul>
                    <li>즐겨찾기 메뉴 추가는 최대 20개로 제한합니다.</li>
                </ul>                    
			</div>

			<div class="btn-group">
				<div class="left">
					<button type="button" class="btn btn-default" onclick="javascript:fnRestCheckBookMark();">초기화</button>
				</div>
				<div class="right">
					<button type="button" class="btn btn-info" onclick="javascript:goSave();">저장</button>
					<button type="button" class="btn btn-info" onclick="javascript:fnClose();">취소</button>
				</div>
			</div>
			
        </div>
    </div>
<!-- /팝업 -->